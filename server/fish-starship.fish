if status is-interactive; and command -q starship
    set -g fish_color_command 94e2d5
    starship init fish | source
end
