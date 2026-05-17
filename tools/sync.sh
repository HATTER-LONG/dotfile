#!/usr/bin/env bash
#
# sync.sh — Bidirectional dotfile sync
#
# Synchronises dotfiles between this repository and your home directory.
#
# Usage:
#   ./sync.sh push [component]   Repo → system (with backup)
#   ./sync.sh pull [component]   System → repo
#   ./sync.sh diff [component]   Show differences
#
# Components:
#   zsh          zsh config files (zshrc, aliases, exports, functions, zprofile, vimrc)
#   tmux         tmux config files
#   kitty        kitty config
#   opencode     opencode config
#   zed          zed config
#   starship     starship prompt config
#   config       All .config/ files (kitty + opencode + zed + starship)
#   all          Everything (default)
#

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly DOTFILE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source shared helpers
if [[ -f "${SCRIPT_DIR}/headfile.sh" ]]; then
	source "${SCRIPT_DIR}/headfile.sh"
fi

# ── File mappings ──────────────────────────────────────────────────────────
# Each entry: repo_relative_path → system_relative_path
# System paths are relative to $HOME.

declare -ra ZSH_MAP=(
	"zshrc/config/zshrc:.zshrc"
	"zshrc/config/aliases:.aliases"
	"zshrc/config/exports:.exports"
	"zshrc/config/functions:.functions"
	"zshrc/config/zprofile:.zprofile"
	"zshrc/config/vimrc:.vimrc"
)

declare -ra TMUX_MAP=(
	"tmux/tmux.conf:.tmux.conf"
	"tmux/tmux.conf.local:.tmux.conf.local"
)

declare -ra KITTY_MAP=(
	"kitty/kitty.conf:.config/kitty/kitty.conf"
)

declare -ra OPENCODE_MAP=(
	"opencode/opencode.jsonc:.config/opencode/opencode.jsonc"
	"opencode/.gitignore:.config/opencode/.gitignore"
)

declare -ra ZED_MAP=(
	"zed/settings.json:.config/zed/settings.json"
	"zed/keymap.json:.config/zed/keymap.json"
)

declare -ra STARSHIP_MAP=(
	"zshrc/starship.toml:.config/starship.toml"
)

# ── Helpers ────────────────────────────────────────────────────────────────

resolve_maps() {
	local component="$1"
	case "${component}" in
		zsh)     printf '%s\n' "${ZSH_MAP[@]}" ;;
		tmux)    printf '%s\n' "${TMUX_MAP[@]}" ;;
		kitty)   printf '%s\n' "${KITTY_MAP[@]}" ;;
		opencode) printf '%s\n' "${OPENCODE_MAP[@]}" ;;
		zed)     printf '%s\n' "${ZED_MAP[@]}" ;;
		starship) printf '%s\n' "${STARSHIP_MAP[@]}" ;;
		config)  printf '%s\n' "${KITTY_MAP[@]}" "${OPENCODE_MAP[@]}" "${ZED_MAP[@]}" "${STARSHIP_MAP[@]}" ;;
		all)     printf '%s\n' "${ZSH_MAP[@]}" "${TMUX_MAP[@]}" "${KITTY_MAP[@]}" "${OPENCODE_MAP[@]}" "${ZED_MAP[@]}" "${STARSHIP_MAP[@]}" ;;
		*)       printf '\n' ;;
	esac
}

list_components() {
	echo "Available components: zsh, tmux, kitty, opencode, zed, starship, config, all"
}

timestamp() {
	date +%Y%m%d%H%M%S
}

backup_file() {
	local src="$1"
	if [[ -f "${src}" ]]; then
		local bak="${src}.bak.$(timestamp)"
		cp -f "${src}" "${bak}"
		prompt_INFO "Backed up ${src} → ${bak}"
	fi
}

# ── Commands ───────────────────────────────────────────────────────────────

run_for_maps() {
	local cmd="$1"
	local maps="$2"
	local entry repo_path sys_path
	local synced=0 skipped=0 uptodate=0 missing_sys=0
	while IFS= read -r entry; do
		[[ -z "${entry}" ]] && continue
		local repo_rel="${entry%%:*}"
		local sys_rel="${entry##*:}"
		repo_path="${DOTFILE_DIR}/${repo_rel}"
		sys_path="${HOME}/${sys_rel}"

		case "${cmd}" in
			push)
				if [[ ! -f "${repo_path}" ]]; then
					warn "Repo file not found: ${repo_rel} — skipping"
					skipped=$((skipped + 1))
					continue
				fi
				local sys_dir
				sys_dir="$(dirname "${sys_path}")"
				if [[ ! -d "${sys_dir}" ]]; then
					mkdir -p "${sys_dir}"
				fi
				if [[ -f "${sys_path}" ]] && ! diff -q "${repo_path}" "${sys_path}" >/dev/null 2>&1; then
					backup_file "${sys_path}"
					cp -f "${repo_path}" "${sys_path}"
					prompt "${repo_rel} → ${sys_rel}  synced"
					synced=$((synced + 1))
				elif [[ ! -f "${sys_path}" ]]; then
					cp -f "${repo_path}" "${sys_path}"
					prompt "${repo_rel} → ${sys_rel}  created"
					synced=$((synced + 1))
				else
					prompt_INFO "${repo_rel} ↔ ${sys_rel}  up-to-date"
					uptodate=$((uptodate + 1))
				fi
				;;
			pull)
				if [[ ! -f "${sys_path}" ]]; then
					warn "System file not found: ${sys_rel} — skipping"
					missing_sys=$((missing_sys + 1))
					continue
				fi
				local repo_dir
				repo_dir="$(dirname "${repo_path}")"
				if [[ ! -d "${repo_dir}" ]]; then
					mkdir -p "${repo_dir}"
				fi
				if [[ -f "${repo_path}" ]] && diff -q "${repo_path}" "${sys_path}" >/dev/null 2>&1; then
					prompt_INFO "${sys_rel} ↔ ${repo_rel}  up-to-date"
					uptodate=$((uptodate + 1))
				else
					cp -f "${sys_path}" "${repo_path}"
					prompt "${sys_rel} → ${repo_rel}  synced"
					synced=$((synced + 1))
				fi
				;;
			diff)
				if [[ ! -f "${repo_path}" ]]; then
					warn "Repo file not found: ${repo_rel}"
					skipped=$((skipped + 1))
					continue
				fi
				if [[ ! -f "${sys_path}" ]]; then
					warn "System file not found: ${sys_rel}"
					missing_sys=$((missing_sys + 1))
					continue
				fi
				if diff -q "${repo_path}" "${sys_path}" >/dev/null 2>&1; then
					prompt_INFO "${repo_rel} ↔ ${sys_rel}  identical"
					uptodate=$((uptodate + 1))
				else
					prompt "${repo_rel} ↔ ${sys_rel}  differs:"
					diff -u "${repo_path}" "${sys_path}" 2>/dev/null || true
					echo
					synced=$((synced + 1))
				fi
				;;
		esac
	done <<< "${maps}"

	local label verb
	case "${cmd}" in
		push) label="synced"   ; verb="Pushed"   ;;
		pull) label="synced"   ; verb="Pulled"   ;;
		diff) label="differing"; verb="Compared" ;;
	esac
	local summary="${verb}: ${synced} ${label}, ${uptodate} up-to-date"
	[[ "${skipped}" -gt 0 ]] && summary+=", ${skipped} skipped"
	[[ "${missing_sys}" -gt 0 ]] && summary+=", ${missing_sys} missing on system"
	prompt "${summary}"
}

cmd_push() {
	local maps="$1"
	run_for_maps push "${maps}"
}

cmd_pull() {
	local maps="$1"
	run_for_maps pull "${maps}"
}

cmd_diff() {
	local maps="$1"
	run_for_maps diff "${maps}"
}

# ── Main ───────────────────────────────────────────────────────────────────

print_help() {
	cat <<'HELP'
sync.sh — Bidirectional dotfile sync

Synchronises dotfiles between this repository and your home directory.

Usage:
  ./sync.sh <command> [component]

Commands:
  push              Copy repo files to system (with automatic backup)
  pull              Copy system files to repo
  diff              Show differences between repo and system

Components:
  zsh               zsh config files
  tmux              tmux config files
  kitty             kitty terminal config
  opencode          opencode AI config
  zed               zed editor config
  starship          starship prompt config
  config            All .config/ files (kitty + opencode + zed + starship)
  all               Everything (default)

Component file mappings:

  zsh:
    zshrc/config/zshrc              → ~/.zshrc
    zshrc/config/aliases            → ~/.aliases
    zshrc/config/exports            → ~/.exports
    zshrc/config/functions          → ~/.functions
    zshrc/config/zprofile           → ~/.zprofile
    zshrc/config/vimrc              → ~/.vimrc

  tmux:
    tmux/tmux.conf                  → ~/.tmux.conf
    tmux/tmux.conf.local            → ~/.tmux.conf.local

  kitty:
    kitty/kitty.conf                → ~/.config/kitty/kitty.conf

  opencode:
    opencode/opencode.jsonc         → ~/.config/opencode/opencode.jsonc
    opencode/.gitignore             → ~/.config/opencode/.gitignore

  zed:
    zed/settings.json               → ~/.config/zed/settings.json
    zed/keymap.json                 → ~/.config/zed/keymap.json

  starship:
    zshrc/starship.toml             → ~/.config/starship.toml

Notes:
  - push creates a timestamped backup (.bak.YYYYMMDDHHMMSS) only when
    the system file differs from the repo file.
  - pull overwrites repo files without backup (git handles history).
  - Use 'diff' to preview changes before pushing or pulling.

Examples:
  ./sync.sh diff                    Check all differences
  ./sync.sh push zsh                Deploy zsh configs to system
  ./sync.sh pull config             Sync .config changes back to repo
  ./sync.sh push tmux               Deploy tmux configs to system
HELP
}

main() {
	if [[ $# -lt 1 || "$1" == "--help" || "$1" == "-h" ]]; then
		print_help
		exit 0
	fi

	local command="$1"
	local component="${2:-all}"

	local maps
	maps="$(resolve_maps "${component}")"
	if [[ -z "${maps}" ]]; then
		abort "Unknown component: ${component}"
		list_components
		exit 1
	fi

	case "${command}" in
		push)
			prompt "Pushing repo → system (component: ${component})"
			cmd_push "${maps}"
			;;
		pull)
			prompt "Pulling system → repo (component: ${component})"
			cmd_pull "${maps}"
			;;
		diff)
			prompt "Diffing repo ↔ system (component: ${component})"
			cmd_diff "${maps}"
			;;
		*)
			abort "Unknown command: ${command}"
			echo "Usage: $0 {push|pull|diff} [component]"
			exit 1
			;;
	esac
}

main "$@"
