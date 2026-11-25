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

    def test_upgrade_stops_on_failed_commands_and_does_not_overwrite_sources(self):
        source = SCRIPT.read_text(encoding="utf-8")
        stage = source.split('elif [[ "$stage" == "7" ]]; then', 1)[1].split('elif [[ "$stage" == "8" ]]; then', 1)[0]
        self.assertIn('if ! "$@"; then', stage)
        self.assertIn('upgrade_step apt update', stage)
        self.assertIn('upgrade_step apt -y -o', stage)
        self.assertIn('upgrade_step mv -T --no-clobber', stage)
        self.assertNotIn('mv -f', stage)
        self.assertIn('[[ "$NEWVER" == "13" ]]', stage)

    def test_documentation_says_no_automatic_backup_or_rollback(self):
        text = README.read_text(encoding="utf-8")
        self.assertIn("не создаёт backup и не выполняет rollback", text)
        self.assertIn("не создаёт резервную копию и не выполняет rollback", text)


if __name__ == "__main__":
    unittest.main()
