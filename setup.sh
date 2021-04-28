#! /bin/bash

cd

install -d -m 0700 .tmp .ssh
install -d -m 0755 .config/git

while read from to
do
    test -e "$from" && continue
    test -e "$(dirname $from)/$to" || continue
    ln -sv "$to" "$from"
done << LINKS
.bashrc .dotfiles/zshrc
.bash_profile .dotfiles/zprofile
.config/git/ignore .dotfiles/gitignore
.ctags .dotfiles/ctags
.gitconfig .dotfiles/gitconfig
.inputrc .dotfiles/inputrc
.pythonrc .dotfiles/pythonrc
.tmux.conf .dotfiles/tmux.conf
.vimrc .dotfiles/vimrc
.zprofile .dotfiles/zprofile
.zshenv .dotfiles/zshenv
.zshrc .dotfiles/zshrc
LINKS

command -v lesskey > /dev/null && lesskey .dotfiles/lesskey

case "$OSTYPE" in
    linux*)
        if [[ $UID = 0 && -f /etc/debian_version ]]
        then
            install -d -m 0755 ~/.aptitude
            ln -nsf ../.dotfiles/aptitude .aptitude/config
        fi
    ;;
esac
