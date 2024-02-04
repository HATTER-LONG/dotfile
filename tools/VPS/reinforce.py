from sshdconf import SSHDConf

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
    def __init__(self):
        self.sshd = SSHDConf()

    def __getMainInfo__(self, keys: list):
        result = {}
        for key in keys:
            result[key] = self.sshd.get(key)
        return result

    def showMainInfoTable(self, keys: list = KEYS):
        result = self.__getMainInfo__(keys)
        for key in keys:
            print(key, ":", result[key])


cs = checkSSHDConfig()
cs.showMainInfoTable()
