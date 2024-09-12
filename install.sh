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
############                 MAIN CONFIG START              ##################
##############################################################################

init() {
	prompt "Start init..."
	cd $HOME
	package_update
	check_and_install sudo
	check_and_install curl
	check_and_install wget
	check_and_install git
	check_and_install ssh
	check_and_install zip
	check_and_install fzf
	check_and_install ripgrep
	check_and_install make
	check_and_install python3

	${DOTFILE_DIR}/tools/update_lazygit.sh
	prompt "Finished init..."
}

neovim() {
	prompt "Start install and config ${tty_bold}neovim${tty_reset}..."
	if ! command -v nvim >/dev/null; then
		if command -v apt-get >/dev/null; then
			# execute sudo apt-get install -y software-properties-common
			# execute sudo add-apt-repository ppa:neovim-ppa/unstable
			# execute sudo apt-get install -y neovim python3-dev python3-pip python3-venv
			${DOTFILE_DIR}/tools/update_neovim.sh 1
		else
			package_install neovim
		fi
	fi
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/HATTER-LONG/nvimdots/HEAD/scripts/install.sh)"
	# execute git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
	# execute git clone https://github.com/HATTER-LONG/AstroUserNvimConfig ~/.config/nvim/lua/user
	prompt "Finished install and config ${tty_bold}neovim${tty_reset}..."
}

zsh() {
	prompt "Start install and config ${tty_bold}zsh${tty_reset}..."
	package_install zsh

	prompt "Installing oh-my-zsh..."
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

	prompt "Installing zsh-autosuggestions..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
		execute git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	else
		warn "Skipping already installed zsh-autosuggestions"
	fi

	# prompt "Installing zsh-completions..."
	# if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]]; then
	# 	execute git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
	# else
	# 	warn "Skipping already installed zsh-completions"
	# fi

	prompt "Installing zsh-syntax-highlighting..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
		execute git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	else
		warn "Skipping already installed zsh-syntax-highlighting"
	fi

	prompt "Installing zsh-vi-mode..."
	if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-vi-mode ]]; then
		execute git clone https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-vi-mode
	else
		warn "Skipping already installed zsh-vi-mode"
	fi

	# prompt "Installing zsh-pure..."
	# if [[ ! -d ~/.zsh/pure ]]; then
	# 	if [[ ! -d ~/.zsh ]]; then
	# 		execute mkdir -p "$HOME/.zsh"
	# 	fi
	# 	execute git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
	# else
	# 	warn "Skipping already installed zsh-pure"
	# fi
	prompt "Installing starship..."
	if ! command -v starship >/dev/null; then
		curl -sS https://starship.rs/install.sh | sh
		execute mkdir -p ~/.config
		execute cp ${DOTFILE_DIR}/zshrc/starship.toml ~/.config/starship.toml
	fi

	prompt "Installing zsh config files..."
	execute cp -f ${DOTFILE_DIR}/zshrc/config/zshrc $HOME/.zshrc
	execute cp -f ${DOTFILE_DIR}/zshrc/config/exports $HOME/.exports
	execute cp -f ${DOTFILE_DIR}/zshrc/config/functions $HOME/.functions
	execute cp -f ${DOTFILE_DIR}/zshrc/config/aliases $HOME/.aliases
	execute cp -f ${DOTFILE_DIR}/zshrc/config/vimrc $HOME/.vimrc

	prompt "Installing eza..."
	check_and_install eza
	prompt "Installing zoxide..."
	check_and_install zoxide
	prompt "Installing bat..."
	check_and_install bat
	if command -v apt-get >/dev/null; then
		prompt "Add catbat[/usr/bin/batcat] to bat[~/.local/bin] soft link for ubuntu..."
		if [[ ! -d ~/.local/bin ]]; then
			mkdir -p ~/.local/bin
		fi
		ln -s /usr/bin/batcat ~/.local/bin/bat
	fi

	prompt "Installing vivid..."
	if command -v apt-get >/dev/null; then
		wget "https://github.com/sharkdp/vivid/releases/download/v0.8.0/vivid_0.8.0_amd64.deb"
		execute sudo dpkg -i vivid_0.8.0_amd64.deb
		rm vivid_0.8.0_amd64.deb
	else
		check_and_install vivid
	fi
	prompt "Finished install and config ${tty_bold}zsh${tty_reset}..."
}

pyenv() {
	prompt "Start install and config ${tty_bold}pyenv${tty_reset}..."
	if ! which pyenv 2>/dev/null; then
		prompt "Installing pyenv..."
		curl https://pyenv.run | bash
	fi
	if which apt-get 2>/dev/null; then
		prompt "Installing pyenv dependencies..."
		execute sudo apt install -y build-essential libssl-dev zlib1g-dev \
			libbz2-dev libreadline-dev libsqlite3-dev curl \
			libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
	elif which brew 2>/dev/null; then
		prompt "Installing pyenv dependencies..."
		execute brew install openssl readline sqlite3 xz zlib
	else
		wait_for_user "Please check pyenv dependencies in https://github.com/pyenv/pyenv/wiki#suggested-build-environment"
	fi
	execute git clone https://github.com/alefpereira/pyenv-pyright.git ~/.pyenv/plugins/pyenv-pyright
	execute cp -f ${DOTFILE_DIR}/zshrc/config/zprofile $HOME/.zprofile
}

fish() {
	prompt "Start install and config ${tty_bold}fish${tty_reset}..."
	package_install fish
	execute cp -f ${DOTFILE_DIR}/fishrc/config.fish $HOME/.config/fish/config.fish
}

rust() {
	prompt "Start install and config ${tty_bold}rust${tty_reset}..."
	if ! command -v rustup >/dev/null; then
		prompt "Installing rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	fi
}

tmux() {
	prompt "Start install and config ${tty_bold}tmux${tty_reset}..."
	check_and_install tmux
	execute cp -f ${DOTFILE_DIR}/tmux/tmux.conf $HOME/.tmux.conf
	execute cp -f ${DOTFILE_DIR}/tmux/tmux.conf.local $HOME/.tmux.conf.local
}

nodejs() {
	prompt "Start install and config ${tty_bold}nodejs${tty_reset}..."
	if command -v apt-get >/dev/null; then
		prompt "Installing nodejs..."
		curl -sL https://deb.nodesource.com/setup_21.x | sudo -E bash -
		sudo apt-get install -y nodejs
	else
		package_install nodejs
	fi
}

clean() {
	execute rm -rf ${DOTFILE_DIR}
}

prompt_confirm "Do you want to install and config ${tty_bold}neovim${tty_reset}?"
NEOVIM_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}zsh${tty_reset}?"
ZSH_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}fish${tty_reset}?"
FISH_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}tmux${tty_reset}?"
TMUX_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}pyenv${tty_reset}?"
PYENV_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}rust${tty_reset}?"
RUST_INSTALL=$?

prompt_confirm "Do you want to install and config ${tty_bold}nodejs${tty_reset}?"
NODEJS_INSTALL=$?
init

if [[ NODEJS_INSTALL -eq 1 ]]; then
	nodejs
fi

if [[ NEOVIM_INSTALL -eq 1 ]]; then
	neovim
fi

if [[ ZSH_INSTALL -eq 1 ]]; then
	zsh
fi

if [[ FISH_INSTALL -eq 1 ]]; then
	fish
fi

if [[ TMUX_INSTALL -eq 1 ]]; then
	tmux
fi

if [[ PYENV_INSTALL -eq 1 ]]; then
	pyenv
fi

if [[ RUST_INSTALL -eq 1 ]]; then
	rust
fi

##############################################################################
############                 MAIN CONFIG END                ##################
##############################################################################
