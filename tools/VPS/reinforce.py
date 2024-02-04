import os
import platform
import subprocess

from myprint import pError, pInfo, pSuccess
from sshdconf import checkSSHDConfig


def restart_sshd():
    system_platform = platform.system().lower()

    if system_platform == "linux":
        try:
            subprocess.run(["sudo", "systemctl", "restart", "ssh"])
        except FileNotFoundError:
            subprocess.run(["sudo", "/etc/init.d/ssh", "restart"])
            # or
            # subprocess.run(["sudo", "service", "ssh", "restart"])

    elif system_platform == "windows":
        subprocess.run(["sc", "stop", "sshd"])
        subprocess.run(["sc", "start", "sshd"])

    else:
        pError("Unsupported operating system")


def harden_SSHD():
    pInfo("Start to harden SSHD config...")
    if not os.path.exists("/etc/ssh/sshd_config"):
        pError("No SSHD config file found! skip harden sshd")
        return
    home_dir = os.path.expanduser("~")
    ssh_public_key_path = os.path.join(home_dir, ".ssh", "id_rsa.pub")
    ssh_auth_key_path = os.path.join(home_dir, ".ssh", "authorized_keys")
    if not os.path.isfile(ssh_public_key_path) and not os.path.exists(
        ssh_auth_key_path
    ):
        pError("Please generate SSH key pair first! skip harden sshd")
        return
    pInfo("show current SSHD config....")
    sshd = checkSSHDConfig()
    sshd.show_info_table()
    pInfo("auto harden SSHD to modify config.....")
    if not sshd.auto_modify_sshd_config():
        pError("Failed to harden SSHD config! skip harden sshd")
        sshd.show_info_table()
        return
    sshd.show_info_table()
    pSuccess("Harden SSHD config successfully!")
    pInfo("Restarting SSHD service...")
    restart_sshd()


if __name__ == "__main__":
    harden_SSHD()
