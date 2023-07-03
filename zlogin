if [[ -n $PATH_ORIG ]]
then
    ppath "zlogin before"
    if [[ -n $CODESPACES ]]
    then
        export PATH=$PATH_PRIO:$PATH:$PATH_DOTFILES:$PATH_LINUXBREW
    else
        export PATH=$PATH_PRIO:$PATH_DOTFILES:$PATH:$PATH_LINUXBREW
    fi
    unset PATH_DOTFILES PATH_LINUXBREW PATH_ORIG PATH_PRIO
fi
ppath "zlogin mid"
typeset -U path
ppath "zlogin after"
