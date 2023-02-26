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

check_and_install() {
	if ! command -v $1 >/dev/null; then
		prompt "Installing "$1"..."
		package_install $1
	else
		echo "$1 is already installed"
	fi
}
##############################################################################
############                 MAIN CONFIG START              ##################
##############################################################################

DOTFILE_DIR="$HOME/dotfile"

init() {
	prompt "Start init..."
	check_and_install curl
	check_and_install wget
	check_and_install git
	check_and_install ssh
	if [[ ! -d ${DOTFILE_DIR} ]]; then
		prompt "Download config tmp files..."
		execute git clone https://github.com/HATTER-LONG/dotfile.git ${DOTFILE_DIR}
	fi
	prompt "Finished init..."
}

neovim() {
	prompt "Start install and config ${tty_bold}neovim${tty_reset}..."
	if ! command -v nvim >/dev/null; then
		package_install neovim
	fi
	if command -v curl >/dev/null 2>&1; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/nvimdots/HEAD/scripts/install.sh)"
	else
		bash -c "$(wget -O- https://raw.githubusercontent.com/HATTER-LONG/nvimdots/HEAD/scripts/install.sh)"
	fi
	prompt "Finished install and config ${tty_bold}neovim${tty_reset}..."
}

zsh() {
	prompt "Start install and config ${tty_bold}zsh${tty_reset}..."
	package_install zsh

	prompt "Installing oh-my-zsh..."
	if command -v curl >/dev/null 2>&1; then
		bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	else
		bash -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi

	prompt "Installing zsh-autosuggestions..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	else
		warn "Skipping already installed zsh-autosuggestions"
	fi

	prompt "Installing zsh-completions..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]]; then
		execute git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
	else
		warn "Skipping already installed zsh-completions"
	fi

	prompt "Installing zsh-vi-mode..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
		execute git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-vi-mode
	else
		warn "Skipping already installed zsh-vi-mode"
	fi

	prompt "Installing zsh-pure..."
	if [[ ! -d ~/.zsh/pure ]]; then
		if [[ ! -d ~/.zsh ]]; then
			execute mkdir -p "$HOME/.zsh"
		fi
		execute git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
	else
		warn "Skipping already installed zsh-pure"
	fi
	prompt "Installing zsh config files..."
	execute cp -f ${DOTFILE_DIR}/zshrc/config/zshrc $HOME/.zshrc
	execute cp -f ${DOTFILE_DIR}/zshrc/config/exports $HOME/.exports
	execute cp -f ${DOTFILE_DIR}/zshrc/config/functions $HOME/.functions
	execute cp -f ${DOTFILE_DIR}/zshrc/config/aliases $HOME/.aliases

	prompt "Installing exa..."
	check_and_install exa
	prompt "Installing zoxide..."
	check_and_install zoxide
	prompt "Installing bat..."
	check_and_install bat
	if [[ $(uname -a) =~ "ubuntu" ]]; then
		prompt "Add catbat[/usr/bin/batcat] to bat[~/.local/bin] soft link for ubuntu..."
		if [[ ! -d ~/.local/bin ]]; then
			mkdir -p ~/.local/bin
		fi
		ln -s /usr/bin/batcat ~/.local/bin/bat
	fi

	prompt "Installing vivid..."
	if [[ $(uname -a) =~ "ubuntu" ]]; then
		wget "https://github.com/sharkdp/vivid/releases/download/v0.8.0/vivid_0.8.0_amd64.deb"
		sudo dpkg -i vivid_0.8.0_amd64.deb
	else
		check_and_install vivid
	fi
	if ! command -v pyenv >/dev/null; then
		prompt "Installing pyenv..."
		curl https://pyenv.run | bash
	fi
	prompt "Finished install and config ${tty_bold}zsh${tty_reset}..."
}

prompt_confirm "Do you want to install and config ${tty_bold}neovim${tty_reset}?"
NEOVIM_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}zsh${tty_reset}?"
ZSH_INSTALL=$?

init

if [[ NEOVIM_INSTALL -eq 1 ]]; then
	neovim
fi

if [[ ZSH_INSTALL -eq 1 ]]; then
	zsh
fi

##############################################################################
############                 MAIN CONFIG END                ##################
##############################################################################
