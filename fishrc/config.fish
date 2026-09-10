# fnm + automatic Node.js version switching.
set -l fnm_path
if set -q XDG_DATA_HOME
    set fnm_path "$XDG_DATA_HOME/fnm"
else
    set fnm_path "$HOME/.local/share/fnm"
end
if test -x "$fnm_path/fnm"
    if not contains -- "$fnm_path" $PATH
        set -gx PATH "$fnm_path" $PATH
    end
end
if command -q fnm; and not set -q FNM_MULTISHELL_PATH
    fnm env --use-on-cd --shell fish | source
end

if test -d "$HOME/.local/bin"
    if not contains -- "$HOME/.local/bin" $PATH
        set -gx PATH "$HOME/.local/bin" $PATH
    end
end
