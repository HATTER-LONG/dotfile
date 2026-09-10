# Interactive shortcuts corresponding to zshrc/config/aliases.

if status is-interactive
    alias ..='cd ..'
    alias ...='cd ../..'
    alias .3='cd ../../..'
    alias .4='cd ../../../..'
    alias .5='cd ../../../../..'

    function ls --description 'List files with eza/exa when available'
        if command -q eza
            command eza --color=auto --icons=auto $argv
        else if command -q exa
            command exa --color=auto --icons $argv
        else
            command ls $argv
        end
    end

    function l --description 'Long file listing'
        if command -q eza
            command eza --color=auto --icons=auto --long --header --git $argv
        else
            ls -l $argv
        end
    end
    function la --description 'Long listing including hidden files'
        ls -lA $argv
    end
    function lr --description 'Recursive listing'
        ls -R $argv
    end

    function cat --description 'Use bat when available'
        if command -q bat
            command bat $argv
        else if command -q batcat
            command batcat $argv
        else
            command cat $argv
        end
    end

    alias grep='grep --color=auto'
    alias cp='cp -iv'
    alias mv='mv -iv'
    alias ln='ln -iv'
    alias mkdir='mkdir -v'
    alias rm='rm -i'
    alias c='clear'
    alias g='git'
    alias h='history'
    alias p='ps axo pid,user,pcpu,comm'
    alias disk='df -h'
    alias ze='zellij'
    alias lz='lazygit'
    alias ni='ninja'

    if command -q nvim
        alias v='nvim'
    else
        alias v='vim'
    end
    if command -q zeditor
        alias zed='zeditor'
    end
    if command -q xdg-open
        alias open='xdg-open'
    end
end
