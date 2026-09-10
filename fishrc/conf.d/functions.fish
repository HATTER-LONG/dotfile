# Reusable Fish-native equivalents of common Zsh functions.

function mkd --description 'Create a directory and enter it'
    if test (count $argv) -ne 1
        echo 'Usage: mkd <directory>' >&2
        return 2
    end
    mkdir -p -- "$argv[1]"; and cd -- "$argv[1]"
end

function readme --description 'Display the first README found'
    for filename in readme.md README.md readme.MD README.MD readme.markdown README.markdown readme.txt README.txt
        if test -f "$filename"
            if command -q glow
                command glow "$filename"
            else
                cat "$filename"
            end
            return
        end
    end
    echo 'No README file found.' >&2
    return 1
end

function weather --description 'Show weather; defaults to Ponorogo'
    set -l location Ponorogo
    if test (count $argv) -gt 0
        set location "$argv[1]"
    end
    curl -fsS "https://wttr.in/$location?m2F&format=v2"
end

function ip-address --description 'Look up IP address information'
    set -l address
    if test (count $argv) -gt 0
        set address "$argv[1]"
    end
    if command -q jq
        curl -fsS -H 'Accept: application/json' "https://ipinfo.io/$address" | jq 'del(.loc, .postal, .readme)'
    else
        curl -fsS -H 'Accept: application/json' "https://ipinfo.io/$address"
    end
end
