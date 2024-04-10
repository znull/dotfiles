if [[ -n $PATH_ORIG ]]
then
    if [[ -n $CODESPACES ]]
    then
        PATH=$PATH_PRIO:$PATH:$PATH_DOTFILES
    else
        PATH=$PATH_PRIO:$PATH_DOTFILES:$PATH
    fi
    [[ -n $PATH_LINUXBREW ]] && PATH=$PATH:$PATH_LINUXBREW
    unset PATH_DOTFILES PATH_LINUXBREW PATH_ORIG PATH_PRIO
    export PATH=$(perl -pe 's/:+/:/g; s/(^:+|:+$)//g' <<<$PATH)
fi
typeset -U path
