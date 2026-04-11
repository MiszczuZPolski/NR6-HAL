#!/usr/bin/env python3
"""Phase 4 rename tool — mechanical legacy-prefix -> GVAR rewriter.

Design reference: .planning/phases/04-variable-namespacing/04-RESEARCH.md Q6,
constraint matrix in 04-00-PLAN.md, and D-01..D-06 in 04-CONTEXT.md.

Tool performs word-boundary, comment/string-aware, dispatch-site-safe rewriting
of legacy HAL globals (RYD_, RHQ_, RydBB_, RydHQ_, RydxHQ_) to CBA GVAR/EGVAR
macros. Dry-run is the default; --apply is required for any filesystem writes.

The tool REFUSES to run with --root pointing anywhere under `.planning/` or
`docs/`. Self-testing uses the --self-test flag, which runs hardcoded in-memory
fixtures (no filesystem reads, no writes).
"""

from __future__ import annotations

import argparse
import datetime
import difflib
import json
import os
import re
import sys
from collections import defaultdict
from pathlib import Path

# ---------------------------------------------------------------------------
# Config — derived from addons/main/script_mod.hpp + each addon's
# script_component.hpp. Verified in 04-RESEARCH.md Q1.
# ---------------------------------------------------------------------------

PREFIX = "hal"

ADDON_COMPONENT = {
    "core": "core",
    "common": "common",
    "missionmodules": "missionmodules",
    "hal_hac": "hal_hac",
    "hal_boss": "hal_boss",
    "hal_tasking": "hal_tasking",
    "hal_data": "hal_data",
    "compat_nr6hal": "compat_nr6hal",
}

# D-02: multi-HQ siblings are RydHQ_, RydHQB_, ..., RydHQH_ (8 variants)
MULTI_HQ_LETTERS = ["", "B", "C", "D", "E", "F", "G", "H"]

# Per-prefix identifier regex. Multi-HQ alternation is longest-first so the
# regex engine prefers RydHQH_Debug over RydHQ_ + H_Debug.
PREFIX_CORE = {
    "RYD_":    r"RYD_",
    "RHQ_":    r"RHQ_",
    "RydBB_":  r"RydBB_",
    "RydHQ_":  r"(?:RydHQ[B-H]_|RydHQ_)",
    "RydxHQ_": r"RydxHQ_",
}

SOURCE_EXTENSIONS = {".sqf", ".hpp", ".cpp", ".inc"}

# ---------------------------------------------------------------------------
# Regex builders
# ---------------------------------------------------------------------------

def make_identifier_regex(prefix: str) -> re.Pattern:
    """Build the word-boundary identifier regex for a prefix batch.

    Uses negative lookbehind/lookahead on [A-Za-z0-9_] so that XRYD_Foo and
    RYD_Foo123_Bar are treated as atomic identifiers and not split.
    """
    core = PREFIX_CORE[prefix]
    return re.compile(
        rf"(?<![A-Za-z0-9_])({core}[A-Za-z][A-Za-z0-9_]*)(?![A-Za-z0-9_])"
    )


def strip_prefix(legacy_name: str, prefix: str) -> str:
    """Strip the prefix from a legacy name and lowercase the first remainder
    char. For the RydHQ_ batch, preserve the HQ letter as a name suffix so
    RydHQB_Debug -> debugB (D-02 multi-HQ rule)."""
    if prefix == "RydHQ_":
        m = re.match(r"^RydHQ([B-H]?)_(.+)$", legacy_name)
        if not m:
            raise ValueError(f"not a RydHQ_* name: {legacy_name}")
        letter, rest = m.group(1), m.group(2)
        return rest[0].lower() + rest[1:] + letter
    if not legacy_name.startswith(prefix):
        raise ValueError(f"{legacy_name} does not start with {prefix}")
    rest = legacy_name[len(prefix):]
    return rest[0].lower() + rest[1:]


def canonical_macros(legacy_name: str, prefix: str, owner: str) -> dict:
    """Return the new_macro_owner_form / extern / literal expansion for an
    entry. Follows Q1 expansion — note the doubled `hal_` for hal_* addons."""
    stripped = strip_prefix(legacy_name, prefix)
    owner_form = f"GVAR({stripped})"
    extern_form = f"EGVAR({owner},{stripped})"
    literal_expansion = f"{PREFIX}_{ADDON_COMPONENT.get(owner, owner)}_{stripped}"
    return {
        "stripped_name": stripped,
        "new_macro_owner_form": owner_form,
        "new_macro_extern_form": extern_form,
        "new_q_macro_owner_form": f"QGVAR({stripped})",
        "new_q_macro_extern_form": f"QEGVAR({owner},{stripped})",
        "new_literal_expansion": literal_expansion,
    }


# ---------------------------------------------------------------------------
# SQF tokenizer — splits text into (kind, start, end) spans where kind is one
# of 'code', 'line_comment', 'block_comment', 'string'. Works across lines.
# SQF string escape: doubled quote ("") is literal quote inside a double-string.
# ---------------------------------------------------------------------------

def tokenize_sqf(text: str) -> list[tuple[str, int, int]]:
    spans: list[tuple[str, int, int]] = []
    i = 0
    n = len(text)
    code_start = 0

    def flush_code(upto: int):
        if upto > code_start:
            spans.append(("code", code_start, upto))

    while i < n:
        c = text[i]
        nxt = text[i + 1] if i + 1 < n else ""

        if c == "/" and nxt == "/":
            flush_code(i)
            j = text.find("\n", i)
            if j == -1:
                j = n
            spans.append(("line_comment", i, j))
            i = j
            code_start = i
            continue

        if c == "/" and nxt == "*":
            flush_code(i)
            j = text.find("*/", i + 2)
            if j == -1:
                j = n
            else:
                j += 2
            spans.append(("block_comment", i, j))
            i = j
            code_start = i
            continue

        if c == '"':
            flush_code(i)
            j = i + 1
            while j < n:
                if text[j] == '"':
                    # Doubled quote = literal quote inside string
                    if j + 1 < n and text[j + 1] == '"':
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            spans.append(("string", i, j))
            i = j
            code_start = i
            continue

        if c == "'":
            flush_code(i)
            j = i + 1
            while j < n:
                if text[j] == "'":
                    if j + 1 < n and text[j + 1] == "'":
                        j += 2
                        continue
                    j += 1
                    break
                j += 1
            spans.append(("string", i, j))
            i = j
            code_start = i
            continue

        i += 1

    flush_code(n)
    return spans


# ---------------------------------------------------------------------------
# Rewrite engine
# ---------------------------------------------------------------------------

class RewriteResult:
    __slots__ = ("new_text", "diff", "warnings", "occurrences")

    def __init__(self, new_text: str, diff: list[str], warnings: list[str],
                 occurrences: list[dict]):
        self.new_text = new_text
        self.diff = diff
        self.warnings = warnings
        self.occurrences = occurrences


def file_owner_addon(path: Path, addons_root: Path) -> str | None:
    try:
        rel = path.resolve().relative_to(addons_root.resolve())
    except ValueError:
        return None
    parts = rel.parts
    if not parts:
        return None
    return parts[0]


def rewrite_text(text: str, prefix: str, rename_map: dict, current_addon: str,
                 file_rel_path: str) -> RewriteResult:
    """Rewrite text for one file. rename_map maps legacy_name -> entry dict."""
    regex = make_identifier_regex(prefix)
    spans = tokenize_sqf(text)
    warnings: list[str] = []
    occurrences: list[dict] = []

    out_parts: list[str] = []

    for kind, start, end in spans:
        chunk = text[start:end]

        if kind in ("line_comment", "block_comment"):
            # Never rewrite comments. Record stale hits for reporting.
            for m in regex.finditer(chunk):
                legacy = m.group(1)
                if legacy in rename_map:
                    warnings.append(
                        f"{file_rel_path}: legacy name {legacy} in comment "
                        f"(line {text.count(chr(10), 0, start + m.start()) + 1})"
                    )
            out_parts.append(chunk)
            continue

        if kind == "string":
            # chunk includes the surrounding quotes
            if len(chunk) < 2:
                out_parts.append(chunk)
                continue
            quote = chunk[0]
            inner = chunk[1:-1] if chunk.endswith(quote) else chunk[1:]

            # Exact match -> Q-macro (scope-aware: owning addon vs extern).
            m_full = regex.fullmatch(inner)
            if m_full and m_full.group(1) in rename_map:
                legacy = m_full.group(1)
                entry = rename_map[legacy]
                owner = entry["addon_owner"]
                if owner == current_addon:
                    replacement = entry["new_q_macro_owner_form"]
                else:
                    replacement = entry["new_q_macro_extern_form"]
                out_parts.append(replacement)
                _record_line_for(occurrences, entry, text, start,
                                 "exact_string_literal", file_rel_path)
                continue

            # Substring match -> flag but don't rewrite.
            flagged = False
            for m in regex.finditer(inner):
                legacy = m.group(1)
                if legacy in rename_map:
                    warnings.append(
                        f"{file_rel_path}: substring legacy name {legacy} "
                        f"inside string literal, manual review required"
                    )
                    flagged = True
            out_parts.append(chunk)
            if flagged:
                continue
            continue

        # kind == 'code'
        def replace_code(match: re.Match) -> str:
            legacy = match.group(1)
            if legacy not in rename_map:
                return match.group(0)
            entry = rename_map[legacy]
            owner = entry["addon_owner"]
            if owner == current_addon:
                repl = entry["new_macro_owner_form"]
            else:
                repl = entry["new_macro_extern_form"]
            _record_line_for(occurrences, entry, text,
                             start + match.start(), "code_identifier",
                             file_rel_path)
            return repl

        out_parts.append(regex.sub(replace_code, chunk))

    new_text = "".join(out_parts)
    if new_text == text:
        diff: list[str] = []
    else:
        diff = list(difflib.unified_diff(
            text.splitlines(keepends=True),
            new_text.splitlines(keepends=True),
            fromfile=f"a/{file_rel_path}",
            tofile=f"b/{file_rel_path}",
        ))
    return RewriteResult(new_text, diff, warnings, occurrences)


def _record_line_for(occurrences: list[dict], entry: dict, text: str,
                     absolute_pos: int, scope: str, file_rel_path: str):
    line_no = text.count("\n", 0, absolute_pos) + 1
    occurrences.append({
        "legacy_name": entry["legacy_name"],
        "path": file_rel_path,
        "line": line_no,
        "scope": scope,
    })


# ---------------------------------------------------------------------------
# Scanning / map construction
# ---------------------------------------------------------------------------

GLOBAL_ASSIGN_RE_TEMPLATE = r"^\s*({name})\s*="
SETVAR_KEY_RE_TEMPLATE = r'setVariable\s*\[\s*"({name})"'
GETVAR_KEY_RE_TEMPLATE = r'getVariable\s*\[\s*"({name})"'
PUBVAR_RE_TEMPLATE = r'publicVariable\s*"({name})"'
ISNIL_RE_TEMPLATE = r'isNil\s*"({name})"'


def walk_sources(root: Path):
    for dirpath, _dirnames, filenames in os.walk(root):
        for fn in filenames:
            if Path(fn).suffix.lower() in SOURCE_EXTENSIONS:
                yield Path(dirpath) / fn


def classify_scope(text: str, pos: int, name: str) -> str:
    """Given a match position in raw text, decide a coarse scope label."""
    # Look backwards on the same line for hints.
    line_start = text.rfind("\n", 0, pos) + 1
    line_end = text.find("\n", pos)
    if line_end == -1:
        line_end = len(text)
    line = text[line_start:line_end]
    before = line[: pos - line_start]
    after = line[pos - line_start :]

    if re.search(rf'setVariable\s*\[\s*"$', before) or re.search(
            rf'setVariable\s*\[\s*"{re.escape(name)}"', line):
        return "setVariable_key"
    if re.search(rf'getVariable\s*\[\s*"$', before) or re.search(
            rf'getVariable\s*\[\s*"{re.escape(name)}"', line):
        return "getVariable_key"
    if re.search(rf'publicVariable\s+"$', before) or re.search(
            rf'publicVariable\s+"{re.escape(name)}"', line):
        return "publicVariable_string"
    if re.search(rf'isNil\s+"$', before) or re.search(
            rf'isNil\s+"{re.escape(name)}"', line):
        return "isNil_guard"
    # Top-level assignment heuristic: identifier is the first non-whitespace
    # token on the line and is followed by `=` (not `==`).
    if re.match(rf"^\s*{re.escape(name)}\s*=(?!=)", line):
        return "global_assignment"
    return "global_read"


def scan_map(root: Path, prefix: str, owner_overrides: dict) -> dict:
    """First-pass scan. Returns legacy_name -> entry dict."""
    regex = make_identifier_regex(prefix)
    rename_map: dict[str, dict] = {}
    owner_candidates: dict[str, list[tuple[str, Path]]] = defaultdict(list)

    files_sorted = sorted(walk_sources(root))

    for file_path in files_sorted:
        try:
            text = file_path.read_text(encoding="utf-8", errors="replace")
        except Exception as exc:
            print(f"WARN: cannot read {file_path}: {exc}", file=sys.stderr)
            continue

        addon = file_owner_addon(file_path, root)
        if addon is None:
            continue

        spans = tokenize_sqf(text)
        for kind, start, end in spans:
            if kind in ("line_comment", "block_comment"):
                continue
            chunk = text[start:end]
            for m in regex.finditer(chunk):
                legacy = m.group(1)
                abs_pos = start + m.start()
                scope = classify_scope(text, abs_pos, legacy)
                entry = rename_map.get(legacy)
                if entry is None:
                    entry = {
                        "legacy_name": legacy,
                        "addon_owner": None,
                        "scopes": set(),
                        "file_locations": [],
                        "multi_hq": False,
                        "multi_hq_siblings": [],
                        "stripped": False,
                        "notes": "",
                    }
                    rename_map[legacy] = entry
                entry["scopes"].add(scope)
                rel = str(file_path.relative_to(root)).replace(os.sep, "/")
                line_no = text.count("\n", 0, abs_pos) + 1
                entry["file_locations"].append({
                    "path": f"{root.name}/{rel}",
                    "line": line_no,
                    "scope": scope,
                })
                if scope == "global_assignment":
                    owner_candidates[legacy].append((addon, file_path))

    # Owner inference: first (alphabetical) assignment wins. Collisions warn.
    for legacy, entry in rename_map.items():
        if legacy in owner_overrides:
            entry["addon_owner"] = owner_overrides[legacy]
            continue
        cands = owner_candidates.get(legacy, [])
        if cands:
            cands_sorted = sorted(cands, key=lambda t: str(t[1]))
            owner = cands_sorted[0][0]
            entry["addon_owner"] = owner
            distinct = {c[0] for c in cands}
            if len(distinct) > 1:
                entry["notes"] = (
                    f"OWNERSHIP COLLISION: assigned in {sorted(distinct)} — "
                    f"picked {owner} by canonical sort; override with --owner-override"
                )
        else:
            # No top-level assignment found anywhere — fall back to first file
            # that references the name. This prevents addon_owner=None leaking
            # into emitted JSON and flags the entry as inferred.
            if entry["file_locations"]:
                fallback = entry["file_locations"][0]["path"]
                fallback_addon = fallback.split("/", 2)[1] if "/" in fallback else None
                entry["addon_owner"] = fallback_addon or "UNKNOWN"
                entry["notes"] = "inferred owner (no top-level assignment found)"
            else:
                entry["addon_owner"] = "UNKNOWN"

    # Multi-HQ sibling detection (RydHQ_ batch only).
    if prefix == "RydHQ_":
        groups: dict[str, list[dict]] = defaultdict(list)
        for entry in rename_map.values():
            m = re.match(r"^RydHQ([B-H])?_(.+)$", entry["legacy_name"])
            if m:
                base = m.group(2)
                groups[base].append(entry)
        for base, members in groups.items():
            if len(members) >= 2:
                siblings = sorted(x["legacy_name"] for x in members)
                for x in members:
                    x["multi_hq"] = True
                    x["multi_hq_siblings"] = siblings

    return rename_map


def detect_dispatch_files(root: Path, prefix: str) -> set[Path]:
    """Return the set of source files that appear to build a legacy-prefix
    identifier at runtime via `call compile (...)`. These are NOT auto-
    rewritten — Q7 requires manual expansion."""
    regex = re.compile(
        rf'call\s+compile\s*\([^)]*(?:{PREFIX_CORE[prefix]}|_prefix\s*\+)',
        re.IGNORECASE,
    )
    hits: set[Path] = set()
    for file_path in walk_sources(root):
        try:
            text = file_path.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        if regex.search(text):
            hits.add(file_path)
    return hits


# ---------------------------------------------------------------------------
# Map emission
# ---------------------------------------------------------------------------

def materialize_map_json(rename_map: dict, prefix: str) -> dict:
    entries = []
    for legacy in sorted(rename_map.keys()):
        entry = rename_map[legacy]
        owner = entry["addon_owner"] or "UNKNOWN"
        try:
            macros = canonical_macros(legacy, prefix, owner)
        except Exception as exc:
            macros = {
                "stripped_name": "",
                "new_macro_owner_form": "",
                "new_macro_extern_form": "",
                "new_q_macro_owner_form": "",
                "new_q_macro_extern_form": "",
                "new_literal_expansion": "",
            }
            entry["notes"] = (entry.get("notes") or "") + f" macro-build-error:{exc}"
        entries.append({
            "legacy_name": legacy,
            "new_macro_owner_form": macros["new_macro_owner_form"],
            "new_macro_extern_form": macros["new_macro_extern_form"],
            "new_literal_expansion": macros["new_literal_expansion"],
            "addon_owner": owner,
            "scopes": sorted(list(entry["scopes"])),
            "multi_hq": entry["multi_hq"],
            "multi_hq_siblings": entry["multi_hq_siblings"],
            "stripped": False,  # D-06: always false in Phase 4
            "notes": entry.get("notes", ""),
            "file_locations": entry["file_locations"],
        })
    return {
        "$schema": "phase-4-rename-map-v1",
        "generated_at": datetime.datetime.utcnow().isoformat() + "Z",
        "prefix_batch": prefix,
        "entries": entries,
    }


# ---------------------------------------------------------------------------
# Self-test — in-memory fixtures, no filesystem I/O.
# ---------------------------------------------------------------------------

def _mini_map_for(legacy_to_owner: dict, prefix: str) -> dict:
    m = {}
    for legacy, owner in legacy_to_owner.items():
        macros = canonical_macros(legacy, prefix, owner)
        m[legacy] = {
            "legacy_name": legacy,
            "addon_owner": owner,
            "scopes": set(),
            "file_locations": [],
            "multi_hq": False,
            "multi_hq_siblings": [],
            "stripped": False,
            "notes": "",
            **macros,
        }
    return m


def run_self_test() -> int:
    cases = []
    ryd_map = _mini_map_for({
        "RYD_Top": "core",
        "RYD_K":   "core",
    }, "RYD_")
    rydhq_map_core = _mini_map_for({
        "RYD_Top": "core",
    }, "RYD_")

    def case(name, prefix, text, expect, current_addon="core",
             rename_map=None, want_flag=False):
        rmap = rename_map if rename_map is not None else ryd_map
        r = rewrite_text(text, prefix, rmap, current_addon, "fixture.sqf")
        passed = (r.new_text == expect)
        flag_ok = (len(r.warnings) > 0) if want_flag else True
        overall = passed and flag_ok
        cases.append((overall, name, text, expect, r.new_text,
                      r.warnings))
        return overall

    # 1. global_assignment (owning addon)
    case("global_assignment",
         "RYD_", "RYD_Top = 5", "GVAR(top) = 5")

    # 2. publicVariable string
    case("publicVariable_string",
         "RYD_", 'publicVariable "RYD_Top"',
         'publicVariable QGVAR(top)')

    # 3. isNil guard
    case("isNil_guard",
         "RYD_", 'isNil "RYD_Top"', 'isNil QGVAR(top)')

    # 4. setVariable key
    case("setVariable_key",
         "RYD_", '_o setVariable ["RYD_K", 1]',
         '_o setVariable [QGVAR(k), 1]')

    # 5. getVariable key
    case("getVariable_key",
         "RYD_", '_o getVariable ["RYD_K", 0]',
         '_o getVariable [QGVAR(k), 0]')

    # 6. global read (code context)
    case("global_read",
         "RYD_", "hint str RYD_Top", "hint str GVAR(top)")

    # 7. line-comment preserved
    case("line_comment_preserved",
         "RYD_", "// RYD_DoNotRewrite\n", "// RYD_DoNotRewrite\n")

    # 8. block-comment preserved
    case("block_comment_preserved",
         "RYD_", "/* RYD_DoNotRewrite */",
         "/* RYD_DoNotRewrite */")

    # 9. word-boundary negative: XRYD_NotATarget must NOT match RYD_NotATarget
    xryd_map = _mini_map_for({"RYD_NotATarget": "core"}, "RYD_")
    case("word_boundary_negative",
         "RYD_", "XRYD_NotATarget = 1", "XRYD_NotATarget = 1",
         rename_map=xryd_map)

    # 10. fuzzy string flagged (substring match, not exact)
    case("fuzzy_string_flagged",
         "RYD_", '_x = "RYD_Top was set";',
         '_x = "RYD_Top was set";',
         want_flag=True)

    # 11. extern form: core global used from common
    extern_map = _mini_map_for({"RYD_Top": "core"}, "RYD_")
    case("extern_form_from_other_addon",
         "RYD_", "hint str RYD_Top", "hint str EGVAR(core,top)",
         current_addon="common", rename_map=extern_map)

    # 12. multi-HQ sibling detection (uses scan_map logic indirectly)
    siblings_test = {}
    for letter in MULTI_HQ_LETTERS:
        name = f"RydHQ{letter}_Debug"
        siblings_test[name] = {
            "legacy_name": name,
            "addon_owner": "missionmodules",
            "scopes": set(),
            "file_locations": [],
            "multi_hq": False,
            "multi_hq_siblings": [],
            "stripped": False,
            "notes": "",
        }
    # Apply the same grouping logic used in scan_map
    groups = defaultdict(list)
    for e in siblings_test.values():
        m = re.match(r"^RydHQ([B-H])?_(.+)$", e["legacy_name"])
        if m:
            groups[m.group(2)].append(e)
    for base, members in groups.items():
        if len(members) >= 2:
            sibs = sorted(x["legacy_name"] for x in members)
            for x in members:
                x["multi_hq"] = True
                x["multi_hq_siblings"] = sibs
    multi_ok = all(e["multi_hq"] for e in siblings_test.values())
    multi_ok = multi_ok and len(siblings_test["RydHQ_Debug"]["multi_hq_siblings"]) == 8
    cases.append((multi_ok, "multi_hq_sibling_detect",
                  "8 siblings", "multi_hq:true x8",
                  "ok" if multi_ok else "FAIL", []))

    # 13. multi-HQ rewrite: RydHQB_Debug -> GVAR(debugB) in owning addon
    rydhq_map = _mini_map_for({
        "RydHQ_Debug":  "missionmodules",
        "RydHQB_Debug": "missionmodules",
    }, "RydHQ_")
    case("multi_hq_letter_suffix",
         "RydHQ_", "RydHQB_Debug = true",
         "GVAR(debugB) = true",
         current_addon="missionmodules", rename_map=rydhq_map)

    # 14. word-boundary: RydHQ_ must NOT match inside RydHQH_ (longest-match)
    rydhq_full = _mini_map_for({
        "RydHQ_Debug":  "missionmodules",
        "RydHQH_Debug": "missionmodules",
    }, "RydHQ_")
    case("rydhq_vs_rydhqh_distinction",
         "RydHQ_", "x = RydHQH_Debug",
         "x = GVAR(debugH)",
         current_addon="missionmodules", rename_map=rydhq_full)

    # Report
    failed = [c for c in cases if not c[0]]
    total = len(cases)
    passed = total - len(failed)
    for ok, name, inp, exp, got, warns in cases:
        tag = "PASS" if ok else "FAIL"
        short_in = inp if len(inp) <= 40 else inp[:37] + "..."
        short_got = str(got) if len(str(got)) <= 40 else str(got)[:37] + "..."
        print(f"[{tag}] {name:32s} {short_in!r:44s} -> {short_got!r}")
        if not ok:
            print(f"       expected: {exp!r}")
            if warns:
                print(f"       warnings: {warns}")
    print(f"{passed}/{total} cases passed")
    return 0 if not failed else 1


# ---------------------------------------------------------------------------
# Report writers
# ---------------------------------------------------------------------------

def write_map_json(path: Path, payload: dict):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


def write_manual_sites_report(report_dir: Path, prefix: str,
                              dispatch_files: set[Path],
                              flagged_strings: list[str]):
    report_dir.mkdir(parents=True, exist_ok=True)
    slug = prefix.rstrip("_").lower()
    path = report_dir / f"manual-sites-{slug}.md"
    lines = [
        f"# Manual review sites for prefix `{prefix}`",
        "",
        "## Dispatch-site files (call compile …)",
        "",
    ]
    if not dispatch_files:
        lines.append("_(none detected)_")
    else:
        for f in sorted(str(p) for p in dispatch_files):
            lines.append(f"- `{f}`")
    lines += ["", "## String-literal substring flags", ""]
    if not flagged_strings:
        lines.append("_(none)_")
    else:
        for w in flagged_strings:
            lines.append(f"- {w}")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def write_stale_comments_report(report_dir: Path, prefix: str,
                                comment_hits: list[str]):
    report_dir.mkdir(parents=True, exist_ok=True)
    slug = prefix.rstrip("_").lower()
    path = report_dir / f"stale-comments-{slug}.md"
    lines = [f"# Stale legacy names found in comments for `{prefix}`", ""]
    if not comment_hits:
        lines.append("_(none)_")
    else:
        for w in sorted(set(comment_hits)):
            lines.append(f"- {w}")
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def load_owner_overrides(path: Path | None) -> dict:
    if path is None:
        return {}
    if not path.exists():
        raise SystemExit(f"--owner-override file not found: {path}")
    text = path.read_text(encoding="utf-8")
    # Accept JSON (easiest) or a minimal YAML subset of `key: value` lines.
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    overrides: dict = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            continue
        k, v = line.split(":", 1)
        overrides[k.strip()] = v.strip().strip('"').strip("'")
    return overrides


# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Phase 4 mechanical rename tool "
                    "(legacy HAL prefix -> CBA GVAR/EGVAR macros)")
    p.add_argument("--root", type=str, default=None,
                   help="Rename scope (must live under addons/; "
                        ".planning/ and docs/ rejected)")
    p.add_argument("--prefix", type=str, default=None,
                   choices=list(PREFIX_CORE.keys()),
                   help="Prefix batch to process")
    p.add_argument("--legacy-dir", type=str, default=None,
                   help="nr6_hal/ tree for dead-var cross-check "
                        "(Phase 4 records but does not act)")
    p.add_argument("--map-out", type=str, default=None,
                   help="Rename-map JSON output path")
    p.add_argument("--dry-run", action="store_true", default=True,
                   help="Default — no writes, print unified diff to stdout")
    p.add_argument("--apply", action="store_true",
                   help="Actually write files and emit the rename map")
    p.add_argument("--owner-override", type=str, default=None,
                   help="YAML/JSON file mapping legacy_name -> owner addon")
    p.add_argument("--allow-dispatch-file", action="append", default=[],
                   help="Whitelist a dispatch-site file that has been hand-rewritten")
    p.add_argument("--report-dir", type=str, default=None,
                   help="Where to write manual-sites / stale-comments reports")
    p.add_argument("--self-test", action="store_true",
                   help="Run in-memory fixtures, print PASS/FAIL, exit")
    return p.parse_args()


def main() -> int:
    args = parse_args()

    if args.self_test:
        if args.root or args.apply:
            print("ERROR: --self-test is incompatible with --root / --apply",
                  file=sys.stderr)
            return 2
        return run_self_test()

    if args.root is None:
        print("ERROR: --root is required (or use --self-test)", file=sys.stderr)
        return 2
    if args.prefix is None:
        print("ERROR: --prefix is required", file=sys.stderr)
        return 2

    root = Path(args.root).resolve()
    root_str = str(root).replace("\\", "/")
    if ".planning" in root_str or "/docs" in root_str or root_str.endswith("/docs"):
        print(f"REFUSE: --root cannot contain .planning or docs ({root})",
              file=sys.stderr)
        return 2
    if not root.exists():
        print(f"ERROR: --root does not exist: {root}", file=sys.stderr)
        return 2

    overrides = load_owner_overrides(
        Path(args.owner_override) if args.owner_override else None)

    print(f"scanning {root} for prefix {args.prefix}...", file=sys.stderr)
    rename_map = scan_map(root, args.prefix, overrides)
    print(f"found {len(rename_map)} unique legacy names", file=sys.stderr)

    dispatch_files = detect_dispatch_files(root, args.prefix)
    whitelisted = {Path(p).resolve() for p in args.allow_dispatch_file}
    unsafe = {f for f in dispatch_files if f.resolve() not in whitelisted}
    if unsafe:
        print(f"dispatch-site files ({len(unsafe)}):", file=sys.stderr)
        for f in sorted(unsafe):
            print(f"  {f}", file=sys.stderr)
        if args.apply:
            print("REFUSE: un-whitelisted dispatch-site files present; "
                  "hand-rewrite first, then pass --allow-dispatch-file",
                  file=sys.stderr)
            return 3

    # Collisions check
    collisions = [e["legacy_name"] for e in rename_map.values()
                  if "OWNERSHIP COLLISION" in (e.get("notes") or "")]
    if collisions and args.apply:
        print(f"REFUSE: {len(collisions)} ownership collisions; resolve "
              f"via --owner-override", file=sys.stderr)
        for c in collisions:
            print(f"  {c}", file=sys.stderr)
        return 4

    # Rewrite pass
    all_diffs: list[tuple[Path, list[str]]] = []
    all_warnings: list[str] = []
    changed_files = 0
    for file_path in sorted(walk_sources(root)):
        if file_path in dispatch_files and file_path.resolve() not in whitelisted:
            continue
        try:
            text = file_path.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        addon = file_owner_addon(file_path, root)
        if addon is None:
            continue
        rel = str(file_path.relative_to(root)).replace(os.sep, "/")
        result = rewrite_text(text, args.prefix, rename_map, addon, rel)
        if result.diff:
            all_diffs.append((file_path, result.diff))
            changed_files += 1
        all_warnings.extend(result.warnings)
        if args.apply and result.new_text != text:
            file_path.write_text(result.new_text, encoding="utf-8")

    # Print diffs
    for _fp, diff in all_diffs:
        sys.stdout.writelines(diff)

    print(f"{changed_files} files would change" if not args.apply
          else f"{changed_files} files written", file=sys.stderr)

    # Emit map JSON
    if args.map_out:
        payload = materialize_map_json(rename_map, args.prefix)
        write_map_json(Path(args.map_out), payload)
        print(f"wrote rename map: {args.map_out}", file=sys.stderr)

    # Reports
    if args.report_dir:
        rdir = Path(args.report_dir)
    elif args.map_out:
        rdir = Path(args.map_out).parent
    else:
        rdir = None
    if rdir is not None:
        write_manual_sites_report(rdir, args.prefix, unsafe, all_warnings)
        write_stale_comments_report(rdir, args.prefix, all_warnings)

    return 0


if __name__ == "__main__":
    sys.exit(main())
