#! /bin/zsh

if [[ $HOSTNAME = *.github.net ]]
then
    if [[ -n $BASH && $- == *i* ]]
    then
        exec zsh -l
    fi

    export EMAIL=znull@github.com
    export PROMPT_COLOR=lightred
fi

[[ -n $GHE_DEV ]] && export PROMPT_COLOR=purple

# on macOS, calling setup_PATH in .zshenv is too early because
# /etc/zprofile will stomp it with eval `/usr/libexec/path_helper -s`
[[ $OSTYPE = darwin* ]] && setup_PATH

umask 022

test -n "$BASH" && source ~/.dotfiles/zshenv

if [ $EUID -eq 0 ]
then
    export NAME=root
else
    export NAME="Jason Lunz"
    export ORGANIZATION='PBR Streetgang'
fi

command -v lesspipe > /dev/null && eval $(lesspipe)

for profile in ~/.config/profile.d/*
do
    source "$profile"
done

test "$BASH" && test -r ~/.bashrc && source ~/.bashrc
