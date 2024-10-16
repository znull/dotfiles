#! /bin/bash

[[ -n $CODESPACES ]] && set -x

cd || exit 1

USER=${USER:-$(id -un)}

if [[ $HOSTNAME = *.github.net || -n $CODESPACES ]]
then
    install -d -m 0700 .csorig
    for cfg in .bash* .profile .zprofile .zsh*
    do
        test -f "$cfg" && mv -nvf "$cfg" .csorig
    done
fi

install -d -m 0700 .tmp .ssh/sockets
install -d -m 0755 bin .config/{env.d,git,profile.d,rc.d} {.config,.local/share}/nvim
touch .config/env.d/local .config/profile.d/local .config/rc.d/local
export PATH=~/bin:$PATH

apt_install() {
    sudo -n apt clean
    sudo -n apt update
    sudo -n apt purge neovim
    sudo -n DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y bat universal-ctags ripgrep socat tmux mosh vim
}

chsh_zsh() {
    if [[ $(getent passwd "$USER") != */zsh ]]
    then
        sudo -n chsh -s /bin/zsh $USER
    fi
}

if [[ -n $CODESPACES ]]
then
    ln -nsfv /workspaces/.codespaces/.persistedshare/dotfiles .dotfiles
    [[ -f .gitconfig ]] && mv -v .gitconfig .config/git/local
    chsh_zsh
    apt_install
    ln -rnsv .dotfiles/browser bin
    [[ -d /workspaces/github ]] && (
        cd /workspaces/github
        git config core.untrackedCache true
        time git log > /dev/null
        time ~/.dotfiles/ghtags
        time git status
    ) &> /workspaces/.codespaces/.persistedshare/warmup.log &
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

case "$OSTYPE" in
    darwin*)
    ;;

    linux*)
        if [[ $(uname -m) = aarch64 ]]
        then
            ver=v10.1.0
            arch=aarch64
            sum=b45c04c8613be390d36685c8a5c6baef690db94ef162b1af93f4cd17bf3bb87a
        else
            ver=v8.2.1
            arch=x86_64
            sum=fc55b17aff9c7a1c2d0fc228b774bb27c33fce72e80fb2425d71bcef22a0cfd8
        fi
        dir=fd-$ver-$arch-unknown-linux-gnu
        url=https://github.com/sharkdp/fd/releases/download/
        curl -sL $url/$ver/$dir.tar.gz | tar -xz -C bin --strip-components=1 $dir/fd
        [[ $(shasum -a 256 bin/fd | tee /dev/stderr) = "$sum  bin/fd" ]] || rm -vf bin/fd

        (
            batcat=$(command -v batcat)
            [[ -n $batcat ]] && ln -nsv $batcat bin/bat
        )

        if [[ $UID = 0 && -f /etc/debian_version ]]
        then
            install -d -m 0755 ~/.aptitude
            ln -nsf ../.dotfiles/aptitude .aptitude/config
        fi
    ;;
esac

if command -v bat > /dev/null
then
    install -d -m 0755 $(bat --config-dir)
    ln -rnsv .dotfiles/bat $(bat --config-file)
fi

ln -rnsv .dotfiles/af bin
ln -rnsv .dotfiles/ctags .ctags
ln -rnsv .dotfiles/ghtags bin
ln -rnsv .dotfiles/gitconfig .gitconfig
ln -rnsv .dotfiles/gitignore .config/git/ignore
ln -rnsv .dotfiles/git-ls-unreachable bin
ln -rnsv .dotfiles/inputrc .inputrc
ln -rnsv .dotfiles/lar bin
ln -rnsv .dotfiles/manpager bin
ln -rnsv .dotfiles/pythonrc .pythonrc
ln -rnsv .dotfiles/tmux.conf .tmux.conf
ln -rnsv .dotfiles/vimrc .vimrc
ln -rnsv .dotfiles/vimrc .config/nvim/init.vim
ln -rnsv .dotfiles/vim .local/share/nvim/site
ln -rnsv .dotfiles/xar bin
ln -rnsv .dotfiles/zlogin .zlogin
ln -rnsv .dotfiles/zprofile .bash_profile
ln -rnsv .dotfiles/zprofile .zprofile
ln -rnsv .dotfiles/zshenv .zshenv
ln -rnsv .dotfiles/zshrc .bashrc
ln -rnsv .dotfiles/zshrc .zshrc

( cd .dotfiles && git split-remote )

# Prefer system tic over linuxbrew's, which doesn't work for some reason
for tic in /usr/bin/tic tic
do
    $tic -xe alacritty,alacritty-direct .dotfiles/alacritty.info && break
done

git -C .dotfiles submodule update --init --recursive

(
    fzf_dir=.dotfiles/vim/pack/plugin/start/fzf
    mkdir -p $fzf_dir/tmp
    mv $fzf_dir/bin/fzf $fzf_dir/tmp
    vim --not-a-term +'call fzf#install()' +qall
    ln -rnsfv $fzf_dir/bin/fzf bin
    fzf --version
)
