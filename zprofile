#! /bin/zsh

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
