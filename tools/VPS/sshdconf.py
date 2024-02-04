import fileinput
import os
import shutil

SSHD_CONFIG_PATH = "/etc/ssh/sshd_config"
SSHD_BACK_CONFIG_PATH = "/etc/ssh/sshd_config.bak"


class SSHDConf:
    """
    This class is used to modify sshd_config file.
    """

    def __init__(self, path=SSHD_CONFIG_PATH, bakpath=SSHD_BACK_CONFIG_PATH):
        self.path = path
        self.bakpath = bakpath

    def backup(self):
        shutil.copyfile(self.path, self.bakpath)

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
