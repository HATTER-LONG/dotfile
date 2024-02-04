#!/bin/bash

# Fail fast with a concise message when not using bash
# Single brackets are needed here for POSIX compatibility
if [ -z "${BASH_VERSION:-}" ]; then
	abort "Bash is required to interpret this script."
fi

# string formatters
if [[ -t 1 ]]; then
	tty_escape() { printf "\033[%sm" "$1"; }
else
	tty_escape() { :; }
fi

tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_yellow="$(tty_escape "0;33")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
	local arg
	printf "%s" "$1"
	shift
	for arg in "$@"; do
		printf " "
		printf "%s" "${arg// /\ }"
	done
}

execute() {
	if ! "$@"; then
		abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
	fi
}

chomp() {
	printf "%s" "${1/"$'\n'"/}"
}

prompt() {
	printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
	printf "${tty_yellow}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

warn_ext() {
	printf "         %s\n" "$(chomp "$1")"
}

getc() {
	local save_state
	save_state="$(/bin/stty -g)"
	/bin/stty raw -echo
	IFS='' read -r -n 1 -d '' "$@"
	/bin/stty "${save_state}"
}

ring_bell() {
	# Use the shell's audible bell.
	if [[ -t 1 ]]; then
		printf "\a"
	fi
}

wait_for_user() {
	local c
	echo
	echo "Press ${tty_bold}RETURN${tty_reset}/${tty_bold}ENTER${tty_reset} to continue or any other key to abort..."
	getc c
	# we test for \r and \n because some stuff does \r instead
	if ! [[ "${c}" == $'\r' || "${c}" == $'\n' ]]; then
		echo "${tty_red}Aborted.${tty_reset}"
		exit 1
	fi
}

prompt_confirm() {
	while true; do
		read -r -p "$1 [Y/n]: " USR_CHOICE
		case "$USR_CHOICE" in
		[yY][eE][sS] | [yY])
			return 1
			;;
		[nN][oO] | [nN])
			return 0
			;;
		*)
			if [[ -z "$USR_CHOICE" ]]; then
				return 1
			fi
			printf "${tty_red}%s\n\n${tty_reset}" "Invalid input! Please enter one of: '[yY]/[yY][eE][sS] / [nN]/[nN][oO]'"
			;;
		esac
	done
}

abort() {
	printf "%s\n" "$@" >&2
	exit 1
}

package_install() {
	if command -v apt-get >/dev/null; then
		execute sudo apt-get install -y $1
	elif command -v dnf >/dev/null; then
		execute sudo dnf install -y $1
	elif command -v yum >/dev/null; then
		execute sudo yum install -y $1
	elif command -v pacman >/dev/null; then
		execute sudo pacman -S $1
	elif command -v brew >/dev/null; then
		execute brew install $1
	else
		abort "Unsupported package manager"
	fi
}

package_update() {
	if command -v apt-get >/dev/null; then
		execute sudo apt-get update
	elif command -v dnf >/dev/null; then
		execute sudo dnf check-update
	elif command -v yum >/dev/null; then
		execute sudo yum check-update
	elif command -v pacman >/dev/null; then
		execute sudo pacman -Syu
	elif command -v brew >/dev/null; then
		execute brew update
	else
		abort "Unsupported package manager"
	fi
}

check_and_install() {
	if ! which $1 2>/dev/null; then
		prompt "Installing "$1"..."
		package_install $1
	else
		echo "$1 is already installed"
	fi
}
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
	harden_SSHD_cfg
fi

if [[ UFW -eq 1 ]]; then
	harden_port_by_UFW
fi
