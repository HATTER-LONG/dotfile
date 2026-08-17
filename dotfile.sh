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

	prompt "System initialisation finished."
}

zsh() {
	prompt "Start install and config ${tty_bold}zsh${tty_reset}..."


	# ----- Starship prompt -----
	prompt "Installing starship..."
	if ! command -v starship >/dev/null 2>&1; then
		#curl -sS https://starship.rs/install.sh | sh
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
	sed -n '/^# /,/^$/p' "$0" | sed 's/^# //'
	exit 0
fi

main "$@"
