#!/usr/bin/env bash
#
# dotifile.sh — Dotfile bootstrapping and installation script.
#
# Clones the dotfile repository (if needed), sources shared helpers, and
# interactively installs and configures a curated set of development tools.
#
# Usage:
#   ./dotifile.sh          Interactive mode (prompts for each component)
#   ./dotifile.sh --help   Show this help message

# ============================================================================
# Strict mode
# ============================================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# Constants
# ============================================================================
readonly DOTFILE_DIR="${HOME}/dotfile"
readonly HEADFILE="${DOTFILE_DIR}/tools/headfile.sh"

# ============================================================================
# Bootstrap — clone the repo and source shared helpers
# ============================================================================
bootstrap() {
	if [[ ! -d "${DOTFILE_DIR}" ]]; then
		printf "==> Downloading dotfile repository...\n"
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

	local pkg
	local -a base_packages=(
		sudo
		vim
		curl
		wget
		git
		ssh
		zip
		fzf
		ripgrep
		make
		cmake
		python3
	)

	for pkg in "${base_packages[@]}"; do
		check_and_install "${pkg}"
	done

	# lazygit: try package manager first, fall back to custom script
	if ! command -v lazygit >/dev/null 2>&1; then
		( check_and_install lazygit ) || true
	fi
	if ! command -v lazygit >/dev/null 2>&1; then
		prompt "lazygit not available via package manager, installing from binary..."
		"${DOTFILE_DIR}/tools/update_lazygit.sh"
	fi

	# ninja: try package manager first, fall back to custom script
	if ! command -v ninja >/dev/null 2>&1; then
		( check_and_install ninja-build ) || true
	fi
	if ! command -v ninja >/dev/null 2>&1; then
		prompt "ninja not available via package manager, installing from binary..."
		"${DOTFILE_DIR}/tools/install_ninja.sh"
	fi

	prompt "System initialisation finished."
}

zsh() {
	prompt "Start install and config ${tty_bold}zsh${tty_reset}..."

	package_install zsh

	prompt "Installing oh-my-zsh..."
	bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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
		curl -sS https://starship.rs/install.sh | sh
		execute mkdir -p "${HOME}/.config"
		execute cp -f "${DOTFILE_DIR}/zshrc/starship.toml" "${HOME}/.config/starship.toml"
	fi

	# ----- Shell configuration files -----
	prompt "Installing zsh config files..."
	execute cp -f "${DOTFILE_DIR}/zshrc/config/zshrc"    "${HOME}/.zshrc"
	execute cp -f "${DOTFILE_DIR}/zshrc/config/exports"  "${HOME}/.exports"
	execute cp -f "${DOTFILE_DIR}/zshrc/config/functions" "${HOME}/.functions"
	execute cp -f "${DOTFILE_DIR}/zshrc/config/aliases"  "${HOME}/.aliases"
	execute cp -f "${DOTFILE_DIR}/zshrc/config/vimrc"    "${HOME}/.vimrc"

	# ----- Modern CLI replacements -----
	prompt "Installing eza..."
	check_and_install eza

	prompt "Installing zoxide..."
	check_and_install zoxide

	prompt "Installing bat..."
	check_and_install bat
	if command -v apt-get >/dev/null 2>&1; then
		prompt "Creating bat symlink for Ubuntu (batcat -> bat)..."
		execute mkdir -p "${HOME}/.local/bin"
		ln -sf /usr/bin/batcat "${HOME}/.local/bin/bat"
	fi

	# ----- Vivid (LS_COLORS generator) -----
	prompt "Installing vivid..."
	if command -v apt-get >/dev/null 2>&1; then
		local vivid_version="0.8.0"
		local vivid_deb="vivid_${vivid_version}_amd64.deb"
		local vivid_url="https://github.com/sharkdp/vivid/releases/download/v${vivid_version}/${vivid_deb}"

		wget "${vivid_url}"
		execute sudo dpkg -i "${vivid_deb}"
		rm -f "${vivid_deb}"
	else
		check_and_install vivid
	fi

	prompt "Finished install and config ${tty_bold}zsh${tty_reset}."
}

kitty() {
	prompt "Start install and config ${tty_bold}kitty${tty_reset}..."

	local kitty_install_dir="${HOME}/.local/kitty.app"
	local kitty_bin_dir="${kitty_install_dir}/bin"

	if [[ ! -d "${kitty_install_dir}" ]]; then
		prompt "Downloading and installing kitty binary..."
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	else
		prompt_INFO "kitty already installed at ${kitty_install_dir}, updating..."
		curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	fi

	# ----- Symlink binaries into PATH -----
	prompt "Creating symlinks for kitty and kitten..."
	execute mkdir -p "${HOME}/.local/bin"
	execute ln -sf "${kitty_bin_dir}/kitty" "${HOME}/.local/bin/kitty"
	execute ln -sf "${kitty_bin_dir}/kitten" "${HOME}/.local/bin/kitten"

	# ----- Desktop integration -----
	if [[ -f "${kitty_install_dir}/share/applications/kitty.desktop" ]]; then
		prompt "Installing kitty desktop entry..."
		execute mkdir -p "${HOME}/.local/share/applications"
		execute cp -f "${kitty_install_dir}/share/applications/kitty.desktop" \
			"${HOME}/.local/share/applications/kitty.desktop"
		execute cp -f "${kitty_install_dir}/share/applications/kitty-open.desktop" \
			"${HOME}/.local/share/applications/kitty-open.desktop"

		# Fix icon and exec paths in the desktop files
		local kitty_icon="${kitty_install_dir}/share/icons/hicolor/256x256/apps/kitty.png"
		sed -i "s|Icon=kitty|Icon=${kitty_icon}|" \
			"${HOME}/.local/share/applications/kitty.desktop" \
			"${HOME}/.local/share/applications/kitty-open.desktop" 2>/dev/null || true
		sed -i "s|Exec=kitty|Exec=${kitty_bin_dir}/kitty|" \
			"${HOME}/.local/share/applications/kitty.desktop" \
			"${HOME}/.local/share/applications/kitty-open.desktop" 2>/dev/null || true
	fi

	# ----- Config -----
	prompt "Deploying kitty config..."
	execute mkdir -p "${HOME}/.config/kitty"
	execute cp -f "${DOTFILE_DIR}/kitty/kitty.conf" "${HOME}/.config/kitty/kitty.conf"

	prompt "Finished install and config ${tty_bold}kitty${tty_reset}."
}

rust() {
	prompt "Start install and config ${tty_bold}rust${tty_reset}..."

	if ! command -v rustup >/dev/null 2>&1; then
		prompt "Installing rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	fi

	prompt "Finished install and config ${tty_bold}rust${tty_reset}."
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
	local font_dst_dir="${HOME}/.local/share/fonts"

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

	prompt "Updating font cache..."
	if command -v fc-cache >/dev/null 2>&1; then
		fc-cache -fv
	else
		execute fc-cache -fv
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

	if prompt_confirm "Do you want to install and config ${tty_bold}rust${tty_reset}?"; then
		rust
	fi

	prompt "All done! Enjoy your new environment."
}

# ---------------------------------------------------------------------------
# Dispatch: honour an explicit --help / -h flag; otherwise run main.
# ---------------------------------------------------------------------------
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
	sed -n '/^# /,/^$/p' "$0" | sed 's/^# //'
	exit 0
fi

main "$@"
