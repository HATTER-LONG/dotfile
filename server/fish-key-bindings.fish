if status is-interactive
    set -g fish_cursor_default block
    set -g fish_cursor_insert line
    if test "$TERM" != dumb
        set -g fish_vi_force_cursor 1
    end

    fish_vi_key_bindings insert
    bind -M insert \ce end-of-line
    bind -M insert jk 'set fish_bind_mode default; commandline -f backward-char repaint'

    if command -q fzf
        fzf --fish | source
    end
end
