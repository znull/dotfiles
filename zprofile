#! /bin/zsh

if [[ $HOSTNAME = *.github.net || -n $CODESPACES ]]
then
    if [[ -n $BASH && $- == *i* ]] && command -v zsh > /dev/null
    then
        set -x
        : .zprofile: replace bash
        exec zsh -l
    fi

    export EMAIL=znull@github.com

    # restore PATH in case ill-behaved system dotfiles overwrote it
    export PATH=$PATH:$PATH_DOTFILES

    case "$GH_ENV" in
        production)    export PROMPT_COLOR=yellow ;;
        staff-wus2-01) export PROMPT_COLOR=green  ;;
        ?*)            export PROMPT_COLOR=black  ;;
        *)
            [[ -n $GHE_DEV ]] && export PROMPT_COLOR=purple
            [[ -n $CODESPACES ]] && export PROMPT_COLOR=cyan
            ;;
    esac

    [[ $HOSTNAME = *-shell-*.github.net ]] && agent ssh

    (
        creation_log=/workspaces/.codespaces/.persistedshare/creation.log
        [[ -f $creation_log ]] && savelog $creation_log
    )
fi

export DOTFILES_INIT_PROFILE=true

umask 022
stty -ixon

test -n "$BASH" && source ~/.dotfiles/zshenv

if [ $EUID -eq 0 ]
then
    export NAME=root
else
    export NAME="Jason Lunz"
    export ORGANIZATION='PBR Streetgang'
fi

for profile in ~/.config/profile.d/*
do
    source "$profile"
done

test "$BASH" && test -r ~/.bashrc && source ~/.bashrc
