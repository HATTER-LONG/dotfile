# Environment shared with the Zsh setup, expressed in native Fish syntax.

set -gx CMAKE_GENERATOR Ninja
set -gx BAT_THEME Nord
set -gx PYTHONDONTWRITEBYTECODE 1
set -gx PIP_REQUIRE_VIRTUALENV true
set -gx ELECTRON_MIRROR https://npmmirror.com/mirrors/electron/
set -gx RUSTUP_UPDATE_ROOT https://mirrors.ustc.edu.cn/rustup/rustup
set -gx RUSTUP_DIST_SERVER https://mirrors.ustc.edu.cn/rust-static
set -gx HOMEBREW_BOTTLE_DOMAIN https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

if command -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR vim
end

for directory in "$HOME/.cargo/bin" "$HOME/WorkSpace/tools/usr/bin" "$HOME/.local/bin"
    if test -d "$directory"; and not contains -- "$directory" $PATH
        set -gx PATH "$directory" $PATH
    end
end

if not set -q TMUX; and test -d /opt/homebrew/include
    set -gx CPLUS_INCLUDE_PATH /opt/homebrew/include $CPLUS_INCLUDE_PATH
end

set -gx FZF_DEFAULT_OPTS '--color=bg+:#302D41,bg:#1E1E2E,spinner:#F8BD96,hl:#F28FAD --color=fg:#D9E0EE,header:#F28FAD,info:#DDB6F2,pointer:#F8BD96 --color=marker:#F8BD96,fg+:#F2CDCD,prompt:#DDB6F2,hl+:#F28FAD'
if command -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f'
end

if command -q vivid
    set -gx LS_COLORS (vivid generate one-dark)
end

if command -q zoxide
    zoxide init fish | source
end
