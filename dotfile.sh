#!/usr/bin/env bash
#
# dotfile.sh — Dotfile bootstrapping and installation script.
#
# Clones the dotfile repository (if needed), sources shared helpers, and
# interactively installs and configures a curated set of development tools.
#
# Usage:
#   ./dotfile.sh          Interactive mode (prompts for each component)
#   ./dotfile.sh --help   Show this help message

# ============================================================================
# Strict mode
# ============================================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# Constants
# ============================================================================
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
if [[ -f "${SCRIPT_DIR}/tools/headfile.sh" ]]; then
	readonly DOTFILE_DIR="${SCRIPT_DIR}"
else
	readonly DOTFILE_DIR="${HOME}/dotfile"
fi
readonly HEADFILE="${DOTFILE_DIR}/tools/headfile.sh"

# ============================================================================
# Bootstrap — clone the repo and source shared helpers
# ============================================================================
bootstrap() {
	if [[ ! -d "${DOTFILE_DIR}" ]]; then
		printf "==> Downloading dotfile repository...\n"
		if ! command -v git >/dev/null 2>&1; then
			printf "ERROR: git is required for the remote bootstrap.\n" >&2
			exit 1
		fi
		git clone https://github.com/HATTER-LONG/dotfile.git "${DOTFILE_DIR}"
	fi

	if [[ ! -f "${HEADFILE}" ]]; then
		printf "ERROR: headfile.sh not found at %s\n" "${HEADFILE}" >&2
		exit 1
	fi

	# shellcheck source=/dev/null
	source "${HEADFILE}"
}

bootstrap

# ============================================================================
# Override prompt_confirm to follow Unix convention (0 = yes, 1 = no)
# so that it plays nicely with 'set -e' and idiomatic 'if' guards.
# ============================================================================
prompt_confirm() {
	local choice
	while true; do
		read -r -p "$1 [Y/n]: " choice
		case "${choice}" in
			[yY][eE][sS]|[yY]|"")
				return 0
				;;
			[nN][oO]|[nN])
				return 1
				;;
			*)
				printf "${tty_red}%s\n\n${tty_reset}" \
					"Invalid input! Please enter: [yY] / [nN]"
				;;
		esac
	done
}

# ============================================================================
# Helper functions
# ============================================================================

# Symlink a file to a destination, backing up any existing file.
link_file() {
	local src="$1"
	local dst="$2"

	if [[ ! -f "${src}" ]]; then
		warn "Source file not found: ${src}"
		return 0
	fi

	if [[ -e "${dst}" && ! -L "${dst}" ]]; then
		warn "Backing up existing file: ${dst} -> ${dst}.bak"
		mv "${dst}" "${dst}.bak"
	fi

	execute ln -sf "${src}" "${dst}"
}

# Clone a Git repository if the target directory does not already exist.
clone_if_missing() {
	local repo_url="$1"
	local target_dir="$2"

	if [[ -d "${target_dir}" ]]; then
		prompt_INFO "Skipping already installed: ${target_dir}"
		return 0
	fi

	execute git clone "${repo_url}" "${target_dir}"
}

# ============================================================================
# Core installation functions
# ============================================================================

init() {
	prompt "Starting system initialisation..."

	cd "${HOME}"

	package_update

	local command_name package
	local -a base_packages=(
		"vim:vim"
		"curl:curl"
		"wget:wget"
		"git:git"
		"zip:zip"
		"fzf:fzf"
		"rg:ripgrep"
		"make:make"
		"cmake:cmake"
		"python3:python3"
	)
	for package in "${base_packages[@]}"; do
		command_name="${package%%:*}"
		check_and_install "${command_name}" "${package##*:}"
	done

	prompt "System initialisation finished."
}

zsh() {
	prompt "Start install and config ${tty_bold}zsh${tty_reset}..."

	check_and_install zsh

	# Install oh-my-zsh without changing the login shell or replacing the
	# repository-managed ~/.zshrc. Skip it when it is already present.
	if [[ ! -f "${HOME}/.oh-my-zsh/oh-my-zsh.sh" ]]; then
		prompt "Installing oh-my-zsh..."
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	else
		prompt_INFO "Skipping already installed: ${HOME}/.oh-my-zsh"
	fi

	# ----- Zsh plugins -----
	local zsh_custom="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

	prompt "Installing zsh-autosuggestions..."
	clone_if_missing \
		"https://github.com/zsh-users/zsh-autosuggestions" \
		"${zsh_custom}/plugins/zsh-autosuggestions"

	prompt "Installing zsh-syntax-highlighting..."
	clone_if_missing \
		"https://github.com/zsh-users/zsh-syntax-highlighting.git" \
		"${zsh_custom}/plugins/zsh-syntax-highlighting"

	prompt "Installing zsh-vi-mode..."
	clone_if_missing \
		"https://github.com/jeffreytse/zsh-vi-mode" \
		"${zsh_custom}/plugins/zsh-vi-mode"

	# ----- Starship prompt -----
	prompt "Installing starship..."
	if ! command -v starship >/dev/null 2>&1; then
		curl -fsSL https://starship.rs/install.sh | sh -s -- -y
	fi
	execute mkdir -p "${HOME}/.config"
	execute cp -f "${DOTFILE_DIR}/zshrc/starship.toml" "${HOME}/.config/starship.toml"

	# ----- Shell configuration files -----
	prompt "Installing zsh config files (symlinked)..."
	link_file "${DOTFILE_DIR}/zshrc/config/zshrc"    "${HOME}/.zshrc"
	link_file "${DOTFILE_DIR}/zshrc/config/exports"  "${HOME}/.exports"
	link_file "${DOTFILE_DIR}/zshrc/config/functions" "${HOME}/.functions"
	link_file "${DOTFILE_DIR}/zshrc/config/aliases"  "${HOME}/.aliases"
	link_file "${DOTFILE_DIR}/zshrc/config/zprofile" "${HOME}/.zprofile"
	execute cp -f "${DOTFILE_DIR}/zshrc/config/vimrc"    "${HOME}/.vimrc"

	# ----- Modern CLI replacements -----
	prompt "Installing eza..."
	check_and_install eza

	prompt "Installing zoxide..."
	check_and_install zoxide

	prompt "Installing bat..."
	if ! command -v bat >/dev/null 2>&1 && ! command -v batcat >/dev/null 2>&1; then
		package_install bat
	fi
	if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
		prompt "Creating bat symlink for Ubuntu (batcat -> bat)..."
		execute mkdir -p "${HOME}/.local/bin"
		execute ln -sf "$(command -v batcat)" "${HOME}/.local/bin/bat"
	fi

	# ----- Vivid (LS_COLORS generator) -----
	prompt "Installing vivid..."
	check_and_install vivid

	prompt "Finished install and config ${tty_bold}zsh${tty_reset}."
}

kitty() {
	prompt "Start install and config ${tty_bold}kitty${tty_reset}..."

	if ! command -v kitty >/dev/null 2>&1; then
		if command -v brew >/dev/null 2>&1; then
			execute brew install --cask kitty
		else
			package_install kitty
		fi
	else
		prompt_INFO "Skipping already installed: kitty"
	fi

	# ----- Config -----
	prompt "Deploying kitty config..."
	execute mkdir -p "${HOME}/.config/kitty"
	execute cp -f "${DOTFILE_DIR}/kitty/kitty.conf" "${HOME}/.config/kitty/kitty.conf"

	prompt "Finished install and config ${tty_bold}kitty${tty_reset}."
}

opencode() {
	prompt "Start deploy ${tty_bold}opencode${tty_reset} config..."

	execute mkdir -p "${HOME}/.config/opencode"
	execute cp -f "${DOTFILE_DIR}/opencode/opencode.jsonc" "${HOME}/.config/opencode/opencode.jsonc"

	prompt "Finished deploy ${tty_bold}opencode${tty_reset} config."
}

cargo() {
	prompt "Start deploy ${tty_bold}cargo${tty_reset} config..."

	execute mkdir -p "${HOME}/.cargo"
	execute cp -f "${DOTFILE_DIR}/cargo/config.toml" "${HOME}/.cargo/config.toml"

	prompt "Finished deploy ${tty_bold}cargo${tty_reset} config."
}

rust() {
	prompt "Start install and config ${tty_bold}rust${tty_reset}..."

	if ! command -v rustup >/dev/null 2>&1; then
		prompt "Installing rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	fi

	prompt "Finished install and config ${tty_bold}rust${tty_reset}."
}

node() {
	prompt "Start install and config ${tty_bold}Node.js${tty_reset} (via nvm)..."

	local nvm_dir="${NVM_DIR:-${HOME}/.nvm}"

	if [[ ! -s "${nvm_dir}/nvm.sh" ]]; then
		prompt "Installing nvm..."
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
	fi

	# Load nvm into the current shell
	export NVM_DIR="${nvm_dir}"
	[[ -s "${NVM_DIR}/nvm.sh" ]] && source "${NVM_DIR}/nvm.sh"

	if ! command -v nvm >/dev/null 2>&1; then
		warn "nvm failed to load, skipping Node.js installation"
		return 0
	fi

	prompt "Installing Node.js LTS via nvm..."
	nvm install --lts

	prompt "Finished install and config ${tty_bold}Node.js${tty_reset} (nvm)."
}

tmux() {
	prompt "Start install and config ${tty_bold}tmux${tty_reset}..."

	check_and_install tmux
	execute cp -f "${DOTFILE_DIR}/tmux/tmux.conf"       "${HOME}/.tmux.conf"
	execute cp -f "${DOTFILE_DIR}/tmux/tmux.conf.local" "${HOME}/.tmux.conf.local"

	prompt "Finished install and config ${tty_bold}tmux${tty_reset}."
}

fonts() {
	prompt "Start installing ${tty_bold}fonts${tty_reset}..."

	local font_src_dir="${DOTFILE_DIR}/font"
	local font_dst_dir
	if [[ "$(uname -s)" == "Darwin" ]]; then
		font_dst_dir="${HOME}/Library/Fonts"
	else
		font_dst_dir="${HOME}/.local/share/fonts"
	fi

	if [[ ! -d "${font_src_dir}" ]]; then
		warn "Font source directory not found: ${font_src_dir}"
		return 0
	fi

	# Count .ttf files
	local ttf_count
	ttf_count=$(find "${font_src_dir}" -maxdepth 1 -name '*.ttf' -type f | wc -l)

	if [[ "${ttf_count}" -eq 0 ]]; then
		warn "No .ttf files found in ${font_src_dir}"
		return 0
	fi

	prompt "Installing ${ttf_count} font(s) to ${font_dst_dir}..."
	execute mkdir -p "${font_dst_dir}"

	local font_file
	for font_file in "${font_src_dir}"/*.ttf; do
		[[ -f "${font_file}" ]] || continue
		execute cp -f "${font_file}" "${font_dst_dir}/"
	done

	if command -v fc-cache >/dev/null 2>&1; then
		prompt "Updating font cache..."
		fc-cache -fv
	fi

	prompt "Finished installing ${tty_bold}fonts${tty_reset}."
}

clean() {
	prompt "Cleaning up dotfile repository at ${DOTFILE_DIR}..."
	execute rm -rf "${DOTFILE_DIR}"
}

# ============================================================================
# Main entry point — interactive prompts and dispatch
# ============================================================================
print_help() {
	cat <<'HELP'
dotfile.sh — interactive development-environment installer

Usage:
  ./dotfile.sh          Install or configure selected components
  ./dotfile.sh --help   Show this help

Supported package managers:
  apt, dnf, yum, pacman, Homebrew

The script uses its own repository directory when run from a clone. When run
through stdin, it clones the repository to ~/dotfile first.
HELP
}

main() {
	# Always run the base init step
	init

	# Prompt for each optional component
	if prompt_confirm "Do you want to install and config ${tty_bold}zsh${tty_reset}?"; then
		zsh
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}tmux${tty_reset}?"; then
		tmux
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}kitty${tty_reset}?"; then
		kitty
	fi

	if prompt_confirm "Do you want to install ${tty_bold}fonts${tty_reset} (TTF)?"; then
		fonts
	fi

	if prompt_confirm "Do you want to deploy ${tty_bold}opencode${tty_reset} config?"; then
		opencode
	fi

	if prompt_confirm "Do you want to deploy ${tty_bold}cargo${tty_reset} config?"; then
		cargo
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}rust${tty_reset}?"; then
		rust
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}Node.js${tty_reset} (via nvm)?"; then
		node
	fi

	prompt "All done! Enjoy your new environment."
}

# ---------------------------------------------------------------------------
# Dispatch: honour an explicit --help / -h flag; otherwise run main.
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	print_help
	exit 0
fi

main "$@"
