if [[ -n $CODESPACES ]]
then
        export PATH=~/bin:$PATH:$DOTFILES_PATH
else
        export PATH=~/bin:$DOTFILES_PATH:$PATH
fi
typeset -U path
unset DOTFILES_PATH
