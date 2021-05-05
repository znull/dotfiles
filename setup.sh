#! /bin/bash

cd

install -d -m 0700 .tmp .ssh/sockets
install -d -m 0755 bin .config/{env.d,git} .vim/{autoload,colors}
touch .config/env.d/local

# GHES
if [[ $USER = build && $HOME = /workspace ]]
then
    sudo -n chsh -s /bin/zsh build
    echo 'export EMAIL=znull@github.com' > ~/.config/env.d/ghes
    echo 'export SSH_AUTH_SOCK=~/.ssh/sockets/secretive' >> ~/.config/env.d/ghes
    gpg --import .dotfiles/5D27B87E.gpg

    rm -f ~/.gitconfig
    sudo apt install exuberant-ctags ripgrep

    ln -rnsv .dotfiles/git-gpg .config/git/gpg
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

case "$OSTYPE" in
    darwin*)
        brew install ascii coreutils ctags daemon fd findutils gh git git-lfs htop jq mosh mtr openssh pstree ripgrep socat tmux tree vim xz zsh-completions
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
vim +'PlugInstall --sync' +qall
ln -rnsv .vim/plugged/fzf/bin/fzf bin
