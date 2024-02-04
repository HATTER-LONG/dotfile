#!/bin/bash

DOTFILE_DIR="$HOME/dotfile"

setup() {
	if [[ ! -d ${DOTFILE_DIR} ]]; then
		echo "Download config tmp files..."
		git clone https://github.com/HATTER-LONG/dotfile.git ${DOTFILE_DIR}
	fi
}

setup

source ${DOTFILE_DIR}/tools/headfile.sh

##############################################################################
############                  START                         ##################
##############################################################################

harden_SSHD_cfg() {
	python3 ./reinforce.py
}

harden_port_by_UFW() {
	check_and_install ufw
	execute ufw default deny incoming
	execute ufw default allow outgoing
	execute ufw allow 22
	execute ufw --force enable
	execute ufw status
}

prompt "=========================="
prompt "Start to harden the server"
prompt "=========================="
prompt_confirm "Do you want to harden ${tty_bold}SSHD CFG${tty_reset}?"
SSHD_CFG=$?
prompt_confirm "Do you want to harden port by ${tty_bold}UFW${tty_reset}?"
UFW=$?

if [[ SSHD_CFG -eq 1 ]]; then
	prompt_INFO "Start to harden SSHD CFG"
	harden_SSHD_cfg
	prompt_INFO "Finish to harden SSHD CFG"
	echo "\n"
fi

if [[ UFW -eq 1 ]]; then
	prompt_INFO "Start to harden port by UFW"
	harden_port_by_UFW
	prompt_INFO "Finish to harden port by UFW"
	echo "\n"
fi
