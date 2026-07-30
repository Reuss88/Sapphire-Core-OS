#!/usr/bin/env python3
"""Validate project-to-Office debrief cross-links."""

from __future__ import annotations

import re
import sys
from pathlib import Path


REQUIRED_FIELDS = (
    "mission_id",
    "project_report",
    "office_debrief",
    "issue",
    "pr",
    "merge_commit",
)


def validate(root: Path) -> list[str]:
    errors: list[str] = []
    bridge_readme = root / "debriefs" / "README.md"
    missions_readme = root / "debriefs" / "missions" / "README.md"
    for path in (bridge_readme, missions_readme):
        if not path.is_file():
            errors.append(f"missing bridge file: {path.relative_to(root)}")

    missions_dir = root / "debriefs" / "missions"
    if not missions_dir.is_dir():
        return errors

    for path in sorted(missions_dir.glob("*.md")):
        if path.name.lower() == "readme.md":
            continue
        text = path.read_text(encoding="utf-8")
        for field in REQUIRED_FIELDS:
            match = re.search(rf"(?m)^{field}:\s*(?P<value>\S+)\s*$", text)
            if not match:
                errors.append(f"{path.relative_to(root)}: missing {field}")
        office_match = re.search(
            r"(?m)^office_debrief:\s*(?P<link>\S+)\s*$", text
        )
        if office_match and "github.com/Reuss88/The-Office/" not in office_match.group(
            "link"
        ):
            errors.append(
                f"{path.relative_to(root)}: office_debrief is not canonical"
            )
        project_match = re.search(
            r"(?m)^project_report:\s*(?P<link>\S+)\s*$", text
        )
        if project_match and "github.com/Reuss88/Sapphire-Core-OS/" not in (
            project_match.group("link")
        ):
            errors.append(
                f"{path.relative_to(root)}: project_report is not canonical"
            )
    return errors


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    errors = validate(root)
    if errors:
        print("Debrief bridge validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1
    print("Debrief bridge validation passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
