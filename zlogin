if [[ -n $PATH_ORIG ]]
then
    if [[ -n $CODESPACES ]]
    then
        export PATH=$PATH_PRIO:$PATH:$PATH_DOTFILES
    else
        export PATH=$PATH_PRIO:$PATH_DOTFILES:$PATH
    fi
    [[ -n $PATH_LINUXBREW ]] && export PATH=$PATH:$PATH_LINUXBREW
    unset PATH_DOTFILES PATH_LINUXBREW PATH_ORIG PATH_PRIO
fi
typeset -U path
