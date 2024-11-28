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

ghbin() {
    local name=$1
    local nwo=$2
    local ver=$3
    local sum=$4
    local arch=$(uname -m)
    [[ $arch = aarch64 ]] || sum=$5

    local dir=$name-$ver-$arch-unknown-linux-gnu
    local url=https://github.com/$nwo/releases/download/

    curl -sL "$url/$ver/$dir.tar.gz" | tar -xz -C bin --strip-components=1 "$dir/$name"
    [[ $(shasum -a 256 "bin/$name" | tee /dev/stderr) = "$sum  bin/$name" ]] || rm -vf "bin/$name"
}

case "$OSTYPE" in
    darwin*)
    ;;

    linux*)
        ghbin fd sharkdp/fd v10.2.0 f03160ccf718e4aa9f1ed85755fa349670a4bebe483bde7dd3ee675ac42decbf eea818be74986760a1436c72135041c6ac3d709eea268554a11356e71f066a8e
        ghbin delta dandavison/delta 0.18.2 7833733f45a128e96757254066b84f6baf553860a656bda4075c32fd735102a0 fad23fba816fec22fc808717a2b4e149d2651e76491f8dd020b4b82d7829a9da

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
