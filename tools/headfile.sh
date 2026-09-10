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

prompt_INFO() {
	printf "${tty_yellow}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
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

execute_as_root() {
	if [[ "${EUID}" -eq 0 ]]; then
		execute "$@"
	elif command -v sudo >/dev/null 2>&1; then
		execute sudo "$@"
	else
		abort "Root privileges are required, but sudo is not installed."
	fi
}

package_install() {
	local package="$1"
	if command -v apt-get >/dev/null 2>&1; then
		execute_as_root apt-get install -y "${package}"
	elif command -v dnf >/dev/null; then
		execute_as_root dnf install -y "${package}"
	elif command -v yum >/dev/null; then
		execute_as_root yum install -y "${package}"
	elif command -v pacman >/dev/null; then
		execute_as_root pacman -S --needed --noconfirm "${package}"
	elif command -v brew >/dev/null; then
		execute brew install "${package}"
	else
		abort "Unsupported package manager"
	fi
}

package_update() {
	if command -v apt-get >/dev/null; then
		execute_as_root apt-get update
	elif command -v dnf >/dev/null; then
		execute_as_root dnf makecache
	elif command -v yum >/dev/null; then
		execute_as_root yum makecache
	elif command -v pacman >/dev/null; then
		execute_as_root pacman -Syu --noconfirm
	elif command -v brew >/dev/null; then
		execute brew update
	else
		abort "Unsupported package manager"
	fi
}

check_and_install() {
	local command_name="$1"
	local package="${2:-$1}"
	if ! command -v "${command_name}" >/dev/null 2>&1; then
		prompt "Installing ${package}..."
		package_install "${package}"
	else
		prompt_INFO "Skipping already installed: ${command_name}"
	fi
}
