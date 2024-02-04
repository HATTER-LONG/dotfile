import fileinput
import os
import shutil
from datetime import datetime

from prettytable import PrettyTable

SSHD_CONFIG_PATH = "/etc/ssh/sshd_config"
SSHD_BACK_CONFIG_PATH = "/etc/ssh/sshd_config.mybak"


class SSHDConf:
    """
    This class is used to modify sshd_config file.
    """

    def __init__(self, path=SSHD_CONFIG_PATH, bakpath=SSHD_BACK_CONFIG_PATH):
        self.path = path
        self.bakpath = bakpath

    def backup(self):
        shutil.copyfile(self.path, self.bakpath + self.generate_backup_filename())

    def generate_backup_filename(self, original_filename=""):
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        return f"{original_filename}.{timestamp}.bak"

    def delbackup(self):
        os.remove(self.bakpath)

    def get(self, key):
        with open(self.path, "r") as f:
            for line in f:
                if line.startswith("#" + key + " "):
                    return line.split()[1] + " (comment)"
                elif line.startswith(key + " "):
                    return line.split()[1]
        return "(default)"

    def modify(self, key, value):
        line_found = False

        with fileinput.FileInput(self.path, inplace=True) as file:
            for line in file:
                if line.startswith("#" + key + " "):
                    print(key + " " + value)
                    line_found = True
                elif line.startswith(key + " "):
                    print(key + " " + value)
                    line_found = True
                else:
                    print(line, end="")
        if not line_found:
            with open(self.path, "a") as file:
                print(key + " " + value, file=file)
            line_found = True
        return line_found

    def comment(self, key):
        with fileinput.FileInput(self.path, inplace=True) as file:
            for line in file:
                if line.startswith(key + " "):
                    print("#" + line, end="")
                else:
                    print(line, end="")


KEYS = [
    "Port",
    "LoginGraceTime",
    "PermitRootLogin",
    "PasswordAuthentication",
    "PermitEmptyPasswords",
    "X11Forwarding",
    "TCPKeepAlive",
    "ClientAliveInterval",
    "ClientAliveCountMax",
    "UseDNS",
    "AllowUsers",
]


class checkSSHDConfig:
    def __init__(self, path="", backup_path=""):
        if path != "" and backup_path != "":
            self.sshd = SSHDConf(path, backup_path)
        else:
            self.sshd = SSHDConf()

    def __get_keylist_info__(self, keys: list):
        result = {}
        for key in keys:
            result[key] = self.sshd.get(key)
        return result

    def show_info_table(self, keys: list = KEYS):
        result = self.__get_keylist_info__(keys)
        table = PrettyTable()
        table.field_names = ["SSHD CFG NAME", "VALUE"]
        for key in keys:
            table.add_row([key, result[key]])
        print(table)

    def auto_modify_sshd_config(self):
        self.sshd.backup()
        result = [
            self.sshd.modify("Port", "22"),
            self.sshd.modify("LoginGraceTime", "2m"),
            self.sshd.modify("PermitRootLogin", "prohibit-password"),
            self.sshd.modify("PasswordAuthentication", "no"),
            self.sshd.modify("PermitEmptyPasswords", "no"),
            self.sshd.modify("X11Forwarding", "no"),
            self.sshd.modify("TCPKeepAlive", "yes"),
            self.sshd.modify("ClientAliveInterval", "300"),
            self.sshd.modify("ClientAliveCountMax", "10"),
            self.sshd.modify("UseDNS", "no"),
            # self.sshd.modify("AllowUsers", "root"),
        ]

        # 检查所有返回值是否都为 True
        if all(result):
            return True
        else:
            return False

    def custom_modif_sshd_config(self, custom_dict: dict):
        self.sshd.backup()
        for key, value in custom_dict.items():
            self.sshd.modify(key, value)


if __name__ == "__main__":
    if not os.path.exists("./sshd_config"):
        shutil.copyfile("/etc/ssh/sshd_config", "./sshd_config")
    cs = checkSSHDConfig("./sshd_config", "./sshd_config.mybak")
    cs.show_info_table()
    cs.auto_modify_sshd_config()
    print("after modify:")
    cs.show_info_table()
