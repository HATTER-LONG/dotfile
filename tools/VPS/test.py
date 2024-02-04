import os
import shutil
import unittest

from sshdconf import SSHDConf

SSHD_CONFIG_PATH = "/etc/ssh/sshd_config"
SSHD_BACK_CONFIG_PATH = "/etc/ssh/sshd_config.bak"
SSHD_TEST_CONFIG_PATH = "./sshd_config"
SSHD_TEST_BACK_CONFIG_PATH = "./sshd_config.bak"


class sshdConfigCtrlTest(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        if not os.path.exists(SSHD_TEST_CONFIG_PATH):
            shutil.copyfile(SSHD_CONFIG_PATH, SSHD_TEST_CONFIG_PATH)

    @classmethod
    def tearDownClass(self):
        if os.path.exists(SSHD_TEST_CONFIG_PATH):
            os.remove(SSHD_TEST_CONFIG_PATH)
        if os.path.exists(SSHD_TEST_BACK_CONFIG_PATH):
            os.remove(SSHD_TEST_BACK_CONFIG_PATH)

    def test_backup(self):
        sshd = SSHDConf(SSHD_TEST_CONFIG_PATH, SSHD_TEST_BACK_CONFIG_PATH)
        sshd.backup()
        self.assertTrue(os.path.exists(SSHD_TEST_BACK_CONFIG_PATH))
        sshd.delbackup()
        self.assertFalse(os.path.exists(SSHD_TEST_BACK_CONFIG_PATH))

    def test_get(self):
        sshd = SSHDConf(SSHD_TEST_CONFIG_PATH, SSHD_TEST_BACK_CONFIG_PATH)
        self.assertEqual(sshd.get("Port"), "22 (comment)", "get failed")
        self.assertEqual(sshd.get("X11"), "(default)", "get failed")
        self.assertEqual(sshd.get("X11Forwarding"), "no (comment)", "get failed")
        self.assertEqual(
            sshd.get("PasswordAuthentication"),
            "yes",
            "get failed",
        )

    def test_modify(self):
        sshd = SSHDConf(SSHD_TEST_CONFIG_PATH, SSHD_TEST_BACK_CONFIG_PATH)
        self.assertTrue(sshd.modify("Port", "2222"), "modify failed")
        self.assertEqual(sshd.get("Port"), "2222", "modify failed")
        self.assertTrue(sshd.modify("NewConfig", "test"), "modify failed")
        self.assertEqual(sshd.get("NewConfig"), "test", "modify failed")
        self.assertTrue(sshd.modify("NewConfig2", "test2"), "modify failed")
        self.assertEqual(sshd.get("NewConfig2"), "test2", "modify failed")

    def test_comment(self):
        sshd = SSHDConf(SSHD_TEST_CONFIG_PATH, SSHD_TEST_BACK_CONFIG_PATH)
        sshd.comment("Port")
        self.assertEqual(sshd.get("Port"), "22 (comment)", "comment failed")
        self.assertTrue(sshd.modify("NeedToComment", "yes"), "modify failed")
        self.assertEqual(sshd.get("NeedToComment"), "yes", "modify failed")
        sshd.comment("NeedToComment")
        self.assertEqual(sshd.get("NeedToComment"), "yes (comment)", "modify failed")


if __name__ == "__main__":
    unittest.main()
