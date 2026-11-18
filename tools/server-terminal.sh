# Shell setup used only by the server preset.

is_rocky_9() (
	[[ -r /etc/os-release ]] || return 1
	# shellcheck source=/dev/null
	. /etc/os-release
	[[ "${ID:-}" == rocky && "${VERSION_ID:-}" == 9.* ]]
)

install_rocky_server_packages() {
	local repo section distribution_tree package
	local -a dnf_args=(--disablerepo='*' --enablerepo=baseos,appstream,extras,crb)
	local -a packages=() epel_args=() tools=(
		git:git curl:curl wget:wget tar:tar unzip:unzip vim:vim-enhanced fc-cache:fontconfig
		fish:fish fzf:fzf rg:ripgrep fd:fd-find bat:bat zoxide:zoxide ninja:ninja-build
	)

	for package in "${tools[@]}"; do
		if ! command -v "${package%%:*}" >/dev/null 2>&1; then
			packages+=("${package##*:}")
		fi
	done
	[[ ${#packages[@]} -gt 0 ]] || return 0

	if [[ -n "${DOTFILE_ROCKY_MIRROR:-}" ]]; then
		for section in baseos:BaseOS appstream:AppStream extras:extras crb:CRB; do
			repo="${section%%:*}"
			distribution_tree="${section##*:}"
			dnf_args+=("--setopt=${repo}.mirrorlist=" \
				"--setopt=${repo}.baseurl=${DOTFILE_ROCKY_MIRROR%/}/${distribution_tree}/\$basearch/os/")
		done
	fi
	if ! rpm -q --quiet epel-release; then
		execute_as_root dnf "${dnf_args[@]}" install -y epel-release
	fi
	epel_args+=(--enablerepo=epel)
	if [[ -n "${DOTFILE_EPEL_MIRROR:-}" ]]; then
		epel_args+=(--setopt=epel.metalink= "--setopt=epel.baseurl=${DOTFILE_EPEL_MIRROR%/}/")
	fi
	execute_as_root dnf "${dnf_args[@]}" "${epel_args[@]}" \
		--setopt=install_weak_deps=False install -y "${packages[@]}"
}

install_server_archive() (
	local binary="$1" url="$2" digest="$3"
	local asset="${url##*/}" temp_dir entry
	command -v "$binary" >/dev/null 2>&1 && return 0
	temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/dotfile-server.XXXXXXXX")"
	trap 'rm -f -- "$temp_dir/$asset" "$temp_dir/$binary"; rmdir -- "$temp_dir"' EXIT

	if [[ -n "${DOTFILE_ASSET_DIR:-}" ]]; then
		cp -- "${DOTFILE_ASSET_DIR}/$asset" "$temp_dir/$asset"
	else
		curl -fLsS --connect-timeout 10 --max-time 300 --retry 2 \
			-o "$temp_dir/$asset" "$url"
	fi
	printf '%s  %s\n' "$digest" "$temp_dir/$asset" | sha256_check

	# Some releases store the binary under a top-level directory.
	entry="$(tar -tzf "$temp_dir/$asset" | awk -F/ -v name="$binary" '$NF == name && !found++ { print }')"
	[[ -n "$entry" ]] || abort "$asset does not contain $binary"
	tar -xOzf "$temp_dir/$asset" -- "$entry" > "$temp_dir/$binary"
	install -m 0755 "$temp_dir/$binary" "${HOME}/.local/bin/$binary"
	prompt "Installed $binary"
)

sha256_check() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum -c -
	else
		shasum -a 256 -c -
	fi
}

install_server_releases() {
	local arch target starship_sha zellij_sha
	case "$(uname -m)" in
		x86_64|amd64) arch=x86_64 ;;
		aarch64|arm64) arch=aarch64 ;;
		*) abort "Unsupported server CPU architecture: $(uname -m)" ;;
	esac
	case "$(uname -s)" in
		Linux) target="$arch-unknown-linux-musl" ;;
		Darwin) target="$arch-apple-darwin" ;;
		*) abort "Unsupported server operating system: $(uname -s)" ;;
	esac
	case "$target" in
		x86_64-unknown-linux-musl)
			starship_sha=10c8eb4cb3b761d9bf59ea828444c2dab36c900b7d69a69e08814b286969df89
			zellij_sha=a8ee599eb357b6142443c91506a4ece3aa8811cb75dcf2b28d194bd66853c79d
			;;
		aarch64-unknown-linux-musl)
			starship_sha=341f5cbf24699fa0b27ec88965ad25f862ea09e15d35a543fd6ffdff1d2aa00d
			zellij_sha=c416b3d29ec9c71baf8754fe66663afe4f615395895e3f9b8b6e3bd0f7042427
			;;
		x86_64-apple-darwin)
			starship_sha=344e4d38787e0aa86dd522ae5462e6fb6da1227691f81a79ffed480a4563ccb3
			zellij_sha=e3b6197af04b286f74f7a9f5f519e5a8cf048be65f0371a32b0d60abac97384a
			;;
		aarch64-apple-darwin)
			starship_sha=5362da8cb2928f98f3ce0ffda697cf0f8de70081db000dae316d6d3a404f6cf0
			zellij_sha=716a1c7887be83cc813900012a156a4d8e0ee1468ac56c58a299c9d8898cdc90
			;;
	esac

	execute mkdir -p "${HOME}/.local/bin"
	install_server_archive starship "https://github.com/starship/starship/releases/download/v1.27.0/starship-${target}.tar.gz" "$starship_sha"
	install_server_archive zellij "https://github.com/zellij-org/zellij/releases/download/v0.46.0/zellij-${target}.tar.gz" "$zellij_sha"
	if [[ "$target" == x86_64-unknown-linux-musl ]]; then
		install_server_archive eza "https://github.com/eza-community/eza/releases/download/v0.23.5/eza_x86_64-unknown-linux-musl.tar.gz" "e06eebab74b73d6b7d51a796a353824b001bea82df077706382e100815d28904"
		install_server_archive vivid "https://github.com/sharkdp/vivid/releases/download/v0.11.1/vivid-v0.11.1-x86_64-unknown-linux-musl.tar.gz" "f1a80a39c75ceae43c4187f302e66c0a45d941ed1479456a0d5ddef665663181"
		install_server_archive lazygit "https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz" "0a23f429a95f0d09db298b3c291536d818de066aa5a85c255806f0490ff6656b"
	fi
}

configure_server_fish() {
	local config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}"
	execute mkdir -p "$config_dir/fish/conf.d"
	link_file "${DOTFILE_DIR}/server/fish-key-bindings.fish" "$config_dir/fish/conf.d/server-key-bindings.fish"
	link_file "${DOTFILE_DIR}/server/fish-starship.fish" "$config_dir/fish/conf.d/starship.fish"
	link_file "${DOTFILE_DIR}/server/starship.toml" "$config_dir/starship.toml"
}

set_default_fish_shell() {
	local fish_shell current_user
	fish_shell="$(command -v fish)"
	current_user="$(id -un)"
	grep -Fxq -- "$fish_shell" /etc/shells || abort "$fish_shell is not listed in /etc/shells"
	if command -v usermod >/dev/null 2>&1; then
		execute_as_root usermod --shell "$fish_shell" "$current_user"
	else
		execute_as_root chsh -s "$fish_shell" "$current_user"
	fi
}
