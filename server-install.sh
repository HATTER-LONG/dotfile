#!/usr/bin/env bash
# Fast, non-interactive server bootstrap.
# Safe to run from a cloned repository or directly through curl/wget.

set -euo pipefail
IFS=$'\n\t'

# Keep fnm and Node downloads bounded; callers may override either value.
export FNM_VERSION="${FNM_VERSION:-v1.39.0}"
export FNM_INSTALL_TIMEOUT="${FNM_INSTALL_TIMEOUT:-900}"

readonly REPOSITORY_URL="${DOTFILE_REPOSITORY_URL:-https://github.com/HATTER-LONG/dotfile.git}"
readonly REPOSITORY_DIR="${DOTFILE_DIR:-${HOME}/dotfile}"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd)"

run_as_root() {
	if [[ "${EUID}" -eq 0 ]]; then
		"$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	else
		printf 'ERROR: root privileges are required, but sudo is unavailable.\n' >&2
		exit 1
	fi
}

install_bootstrap_git() {
	command -v git >/dev/null 2>&1 && return 0
	printf '==> Installing git for repository bootstrap...\n'
	if command -v apt-get >/dev/null 2>&1; then
		run_as_root apt-get update
		run_as_root apt-get install -y git ca-certificates
	elif command -v dnf >/dev/null 2>&1; then
		run_as_root dnf install -y git ca-certificates
	elif command -v yum >/dev/null 2>&1; then
		run_as_root yum install -y git ca-certificates
	elif command -v pacman >/dev/null 2>&1; then
		run_as_root pacman -Sy --needed --noconfirm git ca-certificates
	else
		printf 'ERROR: install git first; this package manager is unsupported.\n' >&2
		exit 1
	fi
}

if [[ -f "${SCRIPT_DIR}/dotfile.sh" && -f "${SCRIPT_DIR}/tools/headfile.sh" ]]; then
	repository_dir="${SCRIPT_DIR}"
else
	install_bootstrap_git
	if [[ -d "${REPOSITORY_DIR}/.git" ]]; then
		printf '==> Reusing %s\n' "${REPOSITORY_DIR}"
	else
		if [[ -e "${REPOSITORY_DIR}" ]]; then
			printf 'ERROR: %s exists but is not a git repository.\n' "${REPOSITORY_DIR}" >&2
			exit 1
		fi
		printf '==> Cloning dotfiles into %s...\n' "${REPOSITORY_DIR}"
		git clone --depth 1 "${REPOSITORY_URL}" "${REPOSITORY_DIR}"
	fi
	repository_dir="${REPOSITORY_DIR}"
fi

exec bash "${repository_dir}/dotfile.sh" --server
