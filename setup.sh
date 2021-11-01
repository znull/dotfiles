#! /bin/bash

[[ -n $CODESPACES ]] && set -x

cd || exit 1

if [[ $HOSTNAME = *.github.net || -n $CODESPACES ]]
then
    rm -vf .bash* .profile
fi

install -d -m 0700 .tmp .ssh/sockets
install -d -m 0755 bin .config/{env.d,git,profile.d,rc.d} .vim/{autoload,colors}
touch .config/env.d/local .config/profile.d/local .config/rc.d/local

if [[ -n $CODESPACES ]]
then
    mv .zshrc .zshrc-codespaces
    ln -nsfv /workspaces/.codespaces/.persistedshare/dotfiles .dotfiles
    [[ -f .gitconfig ]] && mv -v .gitconfig .config/git/local
    if [[ $(getent passwd "$USER") != */zsh ]]
    then
        chsh -s /bin/zsh
    fi
    apt install -y \
        exa \
        exuberant-ctags \
        git/buster-backports \
        git-man/buster-backports \
        golang/buster-backports \
        golang-doc/buster-backports \
        golang-go/buster-backports \
        golang-src/buster-backports
    gem install ripper-tags
    go get -u github.com/jstemmer/gotags
fi

# GHES
if [[ $USER = build && $HOME = /workspace ]]
then
    sudo -n chsh -s /bin/zsh build
    gpg --import .dotfiles/5D27B87E.gpg

    rm -f ~/.gitconfig
    sudo apt install exuberant-ctags ripgrep

    ln -rnsv .dotfiles/git-gpg .config/git/gpg

    sudo dpkg-divert --rename /bin/gpg-agent
    sudo dpkg-divert --rename /usr/bin/gpg-agent
    ln -nsf /bin/true /usr/bin/gpg-agent

    ( cd ~/enterprise2 && git config receive.denyCurrentBranch updateInstead )
fi

ln -rnsv .dotfiles/ctags .ctags
ln -rnsv .dotfiles/gitconfig .gitconfig
ln -rnsv .dotfiles/gitignore .config/git/ignore
ln -rnsv .dotfiles/inputrc .inputrc
ln -rnsv .dotfiles/jellybeans.vim .vim/colors
ln -rnsv .dotfiles/lar bin
ln -rnsv .dotfiles/manpager bin
ln -rnsv .dotfiles/pythonrc .pythonrc
ln -rnsv .dotfiles/tmux.conf .tmux.conf
ln -rnsv .dotfiles/vimrc .vimrc
ln -rnsv .dotfiles/xar bin
ln -rnsv .dotfiles/zprofile .bash_profile
ln -rnsv .dotfiles/zprofile .zprofile
ln -rnsv .dotfiles/zshenv .zshenv
ln -rnsv .dotfiles/zshrc .bashrc
ln -rnsv .dotfiles/zshrc .zshrc

command -v lesskey > /dev/null && lesskey .dotfiles/lesskey

(
    cd .dotfiles
    git remote set-url origin https://github.com/znull/dotfiles.git
    git remote set-url --push origin git@github.com:znull/dotfiles.git
)

case "$OSTYPE" in
    darwin*)
        brew install ascii coreutils ctags daemon fd findutils gh git git-lfs htop jq mosh mtr openssh pstree ripgrep socat tmux tree vim watch xz zsh-completions
    ;;

    linux*)
        ver=v8.2.1
        dir=fd-$ver-x86_64-unknown-linux-gnu
        url=https://github.com/sharkdp/fd/releases/download/
        sum=fc55b17aff9c7a1c2d0fc228b774bb27c33fce72e80fb2425d71bcef22a0cfd8
        curl -sL $url/$ver/$dir.tar.gz | tar -xz -C bin --strip-components=1 $dir/fd
        [[ $(shasum -a 256 bin/fd) = 'fc55b17aff9c7a1c2d0fc228b774bb27c33fce72e80fb2425d71bcef22a0cfd8  bin/fd' ]] || rm -vf bin/fd

        if [[ $UID = 0 && -f /etc/debian_version ]]
        then
            install -d -m 0755 ~/.aptitude
            ln -nsf ../.dotfiles/aptitude .aptitude/config
        fi
    ;;
esac

[[ -s ~/.vim/autoload/plug.vim ]] ||
    curl -fLo ~/.vim/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim --not-a-term +'PlugInstall --sync' +qall
ln -rnsfv .vim/plugged/fzf/bin/fzf bin
