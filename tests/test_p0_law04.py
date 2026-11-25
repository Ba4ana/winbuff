"""Static P0 checks for the Debian upgrade path."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "winbuff.sh"
README = ROOT / "README.md"


class DebianUpgradeSafetyTests(unittest.TestCase):
    def test_debian_upgrade_does_not_create_partial_backup_or_rollback(self):
        source = SCRIPT.read_text(encoding="utf-8")
        for forbidden in ("/root/upgrade-backup", "cp -a /etc/apt/sources.list",
                          "tar -czf /root/upgrade-backup", "rollback()"):
            self.assertNotIn(forbidden, source)

    def test_documentation_says_no_automatic_backup_or_rollback(self):
        text = README.read_text(encoding="utf-8")
        self.assertIn("не создаёт backup и не выполняет rollback", text)
        self.assertIn("не создаёт резервную копию и не выполняет rollback", text)


if __name__ == "__main__":
    unittest.main()
