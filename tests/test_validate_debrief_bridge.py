from __future__ import annotations

import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from validate_debrief_bridge import validate  # noqa: E402


class DebriefBridgeValidationTests(unittest.TestCase):
    def test_repository_fixture_passes(self) -> None:
        self.assertEqual([], validate(ROOT))

    def test_missing_office_link_is_rejected(self) -> None:
        root = ROOT / "tests" / "fixtures" / "project-missing-office-link"
        errors = validate(root)
        self.assertTrue(any("missing office_debrief" in error for error in errors))


if __name__ == "__main__":
    unittest.main()
