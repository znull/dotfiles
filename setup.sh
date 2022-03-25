#! /bin/bash

[[ -n $CODESPACES ]] && set -x

cd || exit 1

USER=${USER:-$(id -un)}

if [[ $HOSTNAME = *.github.net || -n $CODESPACES ]]
then
    rm -vf .bash* .profile
fi

install -d -m 0700 .tmp .ssh/sockets
install -d -m 0755 bin .config/{env.d,git,profile.d,rc.d} {.config,.local/share}/nvim
touch .config/env.d/local .config/profile.d/local .config/rc.d/local

apt_install() {
    sudo -n DEBIAN_FRONTEND=noninteractive apt install -y universal-ctags ripgrep tmux
}

chsh_zsh() {
    if [[ $(getent passwd "$USER") != */zsh ]]
    then
        sudo -n chsh -s /bin/zsh $USER
    fi
}

if [[ -n $CODESPACES ]]
then
    mv .zshrc .zshrc-codespaces
    ln -nsfv /workspaces/.codespaces/.persistedshare/dotfiles .dotfiles
    [[ -f .gitconfig ]] && mv -v .gitconfig .config/git/local
    chsh_zsh
    apt_install
    command -v gem >/dev/null && gem install ripper-tags
    go install github.com/jstemmer/gotags@4c0c4330071a994fbdfdff68f412d768fbcca313
fi

# GHES
if [[ $USER = build && $HOME = /workspace ]]
then
    chsh_zsh
    apt_install

    gpg --import .dotfiles/5D27B87E.gpg

    rm -f ~/.gitconfig

    ln -rnsv .dotfiles/git-gpg .config/git/gpg

    sudo -n dpkg-divert --rename /bin/gpg-agent
    sudo -n dpkg-divert --rename /usr/bin/gpg-agent
    ln -nsf /bin/true /usr/bin/gpg-agent

    ( cd ~/enterprise2 && git config receive.denyCurrentBranch updateInstead )
fi

ln -rnsv .dotfiles/ctags .ctags
ln -rnsv .dotfiles/gh_ssh_shim bin
ln -rnsv .dotfiles/gitconfig .gitconfig
ln -rnsv .dotfiles/gitignore .config/git/ignore
ln -rnsv .dotfiles/inputrc .inputrc
ln -rnsv .dotfiles/lar bin
ln -rnsv .dotfiles/manpager bin
ln -rnsv .dotfiles/pythonrc .pythonrc
ln -rnsv .dotfiles/tmux.conf .tmux.conf
ln -rnsv .dotfiles/vimrc .vimrc
ln -rnsv .dotfiles/vimrc .config/nvim/init.vim
ln -rnsv .dotfiles/vim .local/share/nvim/site
ln -rnsv .dotfiles/xar bin
ln -rnsv .dotfiles/zprofile .bash_profile
ln -rnsv .dotfiles/zprofile .zprofile
ln -rnsv .dotfiles/zshenv .zshenv
ln -rnsv .dotfiles/zshrc .bashrc
ln -rnsv .dotfiles/zshrc .zshrc

command -v lesskey > /dev/null && lesskey .dotfiles/lesskey

( cd .dotfiles && git split-remote )

case "$OSTYPE" in
    darwin*)
        brew install ascii coreutils universal-ctags daemon fd findutils gh git git-lfs htop jq mosh mtr openssh pstree ripgrep socat tmux tree vim watch xz zsh-completions
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

git -C .dotfiles submodule update --init --recursive
ln -rnsfv .dotfiles/vim/pack/plugin/start/fzf/bin/fzf bin
command -v fzf >/dev/null || vim --not-a-term +'call fzf#install()' +qall
