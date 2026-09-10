#!/usr/bin/env bash
#
# dotfile.sh — Dotfile bootstrapping and installation script.
#
# Clones the dotfile repository (if needed), sources shared helpers, and
# installs and configures a curated set of development tools.
#
# Usage:
#   ./dotfile.sh          Interactive mode (prompts for each component)
#   ./dotfile.sh --server Non-interactive server setup
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
readonly FNM_VERSION="${FNM_VERSION:-v1.39.0}"
readonly FNM_INSTALL_TIMEOUT="${FNM_INSTALL_TIMEOUT:-900}"

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

# Run a command with a hard deadline. GNU timeout is normally available on
# Linux servers; gtimeout is provided by coreutils on macOS. The fallback
# watchdog keeps the install bounded on minimal systems as well.
run_with_timeout() {
	local seconds="$1"
	shift

	if command -v timeout >/dev/null 2>&1; then
		timeout --foreground "${seconds}s" "$@"
		return
	fi
	if command -v gtimeout >/dev/null 2>&1; then
		gtimeout --foreground "${seconds}s" "$@"
		return
	fi

	"$@" &
	local command_pid=$!
	(
		sleep "${seconds}"
		kill -TERM "${command_pid}" 2>/dev/null || true
		sleep 2
		kill -KILL "${command_pid}" 2>/dev/null || true
	) &
	local watchdog_pid=$!
	local status=0
	wait "${command_pid}" || status=$?
	kill "${watchdog_pid}" 2>/dev/null || true
	wait "${watchdog_pid}" 2>/dev/null || true
	return "${status}"
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
		"unzip:unzip"
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

	# Vim belongs to the base setup, so server/Fish users get the repository
	# configuration without having to install Zsh.
	link_file "${DOTFILE_DIR}/zshrc/config/vimrc" "${HOME}/.vimrc"

	prompt "System initialisation finished."
}

server_init() {
	prompt "Installing the minimal server base..."

	package_update

	local command_name package
	local -a server_packages=(
		"git:git"
		"curl:curl"
		"wget:wget"
		"vim:vim"
		"tar:tar"
		"unzip:unzip"
		"fc-cache:fontconfig"
	)
	for package in "${server_packages[@]}"; do
		command_name="${package%%:*}"
		check_and_install "${command_name}" "${package##*:}"
	done

	link_file "${DOTFILE_DIR}/zshrc/config/vimrc" "${HOME}/.vimrc"
	prompt "Minimal server base finished."
}

install_fish() {
	prompt "Start install and config ${tty_bold}fish${tty_reset}..."

	check_and_install fish
	execute mkdir -p "${HOME}/.config/fish/conf.d"
	link_file "${DOTFILE_DIR}/fishrc/config.fish" "${HOME}/.config/fish/config.fish"

	local fish_config
	for fish_config in exports aliases functions; do
		link_file \
			"${DOTFILE_DIR}/fishrc/conf.d/${fish_config}.fish" \
			"${HOME}/.config/fish/conf.d/${fish_config}.fish"
	done

	prompt "Finished install and config ${tty_bold}fish${tty_reset}."
}

install_zsh() {
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

install_kitty() {
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

deploy_opencode() {
	prompt "Start deploy ${tty_bold}opencode${tty_reset} config..."

	execute mkdir -p "${HOME}/.config/opencode"
	execute cp -f "${DOTFILE_DIR}/opencode/opencode.jsonc" "${HOME}/.config/opencode/opencode.jsonc"

	prompt "Finished deploy ${tty_bold}opencode${tty_reset} config."
}

deploy_cargo() {
	prompt "Start deploy ${tty_bold}cargo${tty_reset} config..."

	execute mkdir -p "${HOME}/.cargo"
	execute cp -f "${DOTFILE_DIR}/cargo/config.toml" "${HOME}/.cargo/config.toml"

	prompt "Finished deploy ${tty_bold}cargo${tty_reset} config."
}

install_rust() {
	prompt "Start install and config ${tty_bold}rust${tty_reset}..."

	if ! command -v rustup >/dev/null 2>&1; then
		prompt "Installing rust..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	fi

	prompt "Finished install and config ${tty_bold}rust${tty_reset}."
}

nodejs() {
	prompt "Start install and config ${tty_bold}Node.js${tty_reset} (via fnm)..."

	local fnm_dir="${FNM_DIR:-${XDG_DATA_HOME:-${HOME}/.local/share}/fnm}"
	local fnm_bin="${fnm_dir}/fnm"
	local node_mirror="${FNM_NODE_DIST_MIRROR:-https://nodejs.org/dist}"

	if ! command -v fnm >/dev/null 2>&1 && [[ ! -x "${fnm_bin}" ]]; then
		prompt "Installing fnm ${FNM_VERSION}..."
		local fnm_installer
		fnm_installer="$(mktemp "${TMPDIR:-/tmp}/fnm-install.XXXXXX")"
		if ! curl -fL --connect-timeout 10 --max-time 120 --retry 3 \
			-o "${fnm_installer}" "https://fnm.vercel.app/install"; then
			rm -f "${fnm_installer}"
			abort "Failed to download the fnm installer."
		fi
		if ! run_with_timeout 180 bash "${fnm_installer}" \
			--install-dir "${fnm_dir}" \
			--release "${FNM_VERSION}" \
			--skip-shell \
			--force-install; then
			rm -f "${fnm_installer}"
			abort "fnm installation timed out or failed."
		fi
		rm -f "${fnm_installer}"
	fi

	if command -v fnm >/dev/null 2>&1; then
		fnm_bin="$(command -v fnm)"
	elif [[ -x "${fnm_bin}" ]]; then
		export PATH="${fnm_dir}:${PATH}"
	else
		abort "fnm failed to install or is not executable."
	fi

	prompt "Resolving the latest Node.js LTS via fnm..."
	local latest_lts
	if ! latest_lts="$(FNM_NODE_DIST_MIRROR="${node_mirror}" FNM_LOGLEVEL=quiet \
		run_with_timeout 120 "${fnm_bin}" list-remote --lts --latest)"; then
		abort "Failed to resolve the latest Node.js LTS. Re-run later or set FNM_NODE_DIST_MIRROR to a trusted mirror."
	fi
	latest_lts="${latest_lts%%[[:space:]]*}"
	if [[ -z "${latest_lts}" || "${latest_lts}" != v* ]]; then
		abort "fnm returned an invalid Node.js LTS version: ${latest_lts:-<empty>}"
	fi

	if [[ -x "${fnm_dir}/node-versions/${latest_lts}/installation/bin/node" ]]; then
		prompt_INFO "Skipping already installed: Node.js ${latest_lts}"
	else
		prompt "Installing Node.js ${latest_lts} via fnm (timeout: ${FNM_INSTALL_TIMEOUT}s)..."
		if ! FNM_NODE_DIST_MIRROR="${node_mirror}" FNM_LOGLEVEL=error \
			run_with_timeout "${FNM_INSTALL_TIMEOUT}" "${fnm_bin}" \
			install "${latest_lts}" --progress never; then
			abort "Node.js LTS installation timed out or failed. Re-run later or set FNM_NODE_DIST_MIRROR to a trusted mirror."
		fi
	fi

	"${fnm_bin}" default "${latest_lts}"
	eval "$("${fnm_bin}" env --shell bash)"
	"${fnm_bin}" use default >/dev/null

	prompt "Finished install and config ${tty_bold}Node.js $(node --version)${tty_reset} (fnm)."
}

install_zellij() {
	prompt "Start install ${tty_bold}Zellij${tty_reset}..."

	if command -v zellij >/dev/null 2>&1; then
		prompt_INFO "Skipping already installed: zellij"
		return 0
	fi

	local arch target asset base_url temp_dir
	case "$(uname -m)" in
		x86_64|amd64) arch="x86_64" ;;
		aarch64|arm64) arch="aarch64" ;;
		*) abort "Unsupported Zellij CPU architecture: $(uname -m)" ;;
	esac
	case "$(uname -s)" in
		Linux) target="${arch}-unknown-linux-musl" ;;
		Darwin) target="${arch}-apple-darwin" ;;
		*) abort "Unsupported Zellij operating system: $(uname -s)" ;;
	esac

	asset="zellij-${target}.tar.gz"
	base_url="https://github.com/zellij-org/zellij/releases/latest/download"
	temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/zellij-install.XXXXXX")"
	if ! curl -fL --connect-timeout 10 --max-time 300 --retry 3 \
		-o "${temp_dir}/${asset}" "${base_url}/${asset}" ||
		! curl -fL --connect-timeout 10 --max-time 60 --retry 3 \
		-o "${temp_dir}/${asset}.sha256sum" "${base_url}/${asset%.tar.gz}.sha256sum"; then
		rm -rf "${temp_dir}"
		abort "Failed to download Zellij."
	fi

	if ! (
		cd "${temp_dir}"
		if command -v sha256sum >/dev/null 2>&1; then
			sha256sum -c "${asset}.sha256sum"
		else
			shasum -a 256 -c "${asset}.sha256sum"
		fi
		tar -xzf "${asset}" zellij
	); then
		rm -rf "${temp_dir}"
		abort "Zellij checksum verification or extraction failed."
	fi
	execute mkdir -p "${HOME}/.local/bin"
	if ! install -m 0755 "${temp_dir}/zellij" "${HOME}/.local/bin/zellij"; then
		rm -rf "${temp_dir}"
		abort "Failed to install Zellij into ${HOME}/.local/bin."
	fi
	rm -rf "${temp_dir}"

	prompt "Finished install ${tty_bold}Zellij${tty_reset}."
}

install_tmux() {
	prompt "Start install and config ${tty_bold}tmux${tty_reset}..."

	check_and_install tmux
	execute cp -f "${DOTFILE_DIR}/tmux/tmux.conf"       "${HOME}/.tmux.conf"
	execute cp -f "${DOTFILE_DIR}/tmux/tmux.conf.local" "${HOME}/.tmux.conf.local"

	prompt "Finished install and config ${tty_bold}tmux${tty_reset}."
}

install_fonts() {
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

server() {
	prompt "Starting non-interactive server setup..."
	server_init
	install_fish
	nodejs
	install_zellij
	install_fonts
	prompt "Server setup finished. Start a new Fish session with: fish"
}

# ============================================================================
# Main entry point — interactive prompts and dispatch
# ============================================================================
print_help() {
	cat <<'HELP'
dotfile.sh — interactive development-environment installer

Usage:
  ./dotfile.sh          Install or configure selected components
  ./dotfile.sh --server Install the server preset without prompts
  ./dotfile.sh --help   Show this help

Server preset:
  git, fish, fnm + Node.js LTS, Zellij, fonts, Vim + vimrc, curl, wget

Environment overrides:
  FNM_VERSION               fnm release tag (default: v1.39.0)
  FNM_INSTALL_TIMEOUT       Node installation deadline in seconds (default: 900)
  FNM_NODE_DIST_MIRROR      Trusted Node.js distribution mirror

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
		install_zsh
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}fish${tty_reset}?"; then
		install_fish
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}tmux${tty_reset}?"; then
		install_tmux
	fi

	if prompt_confirm "Do you want to install ${tty_bold}Zellij${tty_reset}?"; then
		install_zellij
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}kitty${tty_reset}?"; then
		install_kitty
	fi

	if prompt_confirm "Do you want to install ${tty_bold}fonts${tty_reset} (TTF)?"; then
		install_fonts
	fi

	if prompt_confirm "Do you want to deploy ${tty_bold}opencode${tty_reset} config?"; then
		deploy_opencode
	fi

	if prompt_confirm "Do you want to deploy ${tty_bold}cargo${tty_reset} config?"; then
		deploy_cargo
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}rust${tty_reset}?"; then
		install_rust
	fi

	if prompt_confirm "Do you want to install and config ${tty_bold}Node.js${tty_reset} (via fnm)?"; then
		nodejs
	fi

	prompt "All done! Enjoy your new environment."
}

# ---------------------------------------------------------------------------
# Dispatch: honour an explicit --help / -h flag; otherwise run main.
# ---------------------------------------------------------------------------
case "${1:-}" in
	--help|-h)
		print_help
		;;
	--server)
		server
		;;
	"")
		main
		;;
	*)
		printf "ERROR: Unknown option: %s\n\n" "$1" >&2
		print_help >&2
		exit 2
		;;
esac
