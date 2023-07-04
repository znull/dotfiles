#! /bin/zsh

PATH_ORIG=$PATH
PATH=

pappend() {
    if [[ -d $1 ]]
    then
        [[ -n $PATH ]] && PATH=$PATH:
        PATH=$PATH$1
    fi
}

for dir in \
    ~/bin \
    ~/.cargo/bin \
    ~/go/bin \
    /usr/local/opt/coreutils/libexec/gnubin \
    /usr/local/opt/findutils/libexec/gnubin
do
    pappend "$dir"
done

PATH_PRIO=$PATH

for dir in \
    "$GO_INSTALL_PATH" \
    /usr/local/sbin \
    /usr/local/bin \
    /sbin \
    /bin \
    /usr/sbin \
    /usr/bin \
    '/Applications/VMware Fusion.app/Contents/Library' \
    '/Applications/VMware Fusion.app/Contents/Public'
do
    pappend "$dir"
done

unset -f pappend

[[ -r /data/github/shell/bin/gh-environment ]] && source /data/github/shell/bin/gh-environment

if [[ -n $CODESPACES ]]
then
    [[ -z $LANG ]] && export LANG=C.utf-8
    export BROWSER=browser
    [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv | sed -e 's/export PATH=/export PATH_LINUXBREW=/')"
    PATH=$PATH:$PATH_LINUXBREW
fi

PATH=$PATH:$PATH_ORIG
PATH_DOTFILES=$PATH
export PATH

export DVORAK=true
export EDITOR=vim
export VISUAL=$EDITOR
export FZF_CTRL_T_COMMAND='fd --type file --color=always'
export FZF_DEFAULT_COMMAND=$FZF_CTRL_T_COMMAND
export FZF_DEFAULT_OPTS='--ansi'
export HOSTNAME=${HOSTNAME:-"$(hostname)"}
export LESS='-iqsMRXSF -x4'	# added for psql: SFx4
export MANOPT=-Pmanpager
export MANPAGER=manpager
[[ $- = *i* ]] && export MOSH_ESCAPE_KEY=$(echo -e '\x1c')        # fixes C-^ switching in vim
export PAGER=less
export PYTHONSTARTUP=~/.pythonrc
export TZ_LIST='America/Los_Angeles;America/Denver;America/Chicago;America/New_York;UTC;Europe/London' #;Europe/Berlin
export UNAME=$(uname)

# github.com goproxy https://github.com/github/goproxy/blob/main/doc/user.md#set-up
export GOPROXY=https://goproxy.githubapp.com/mod,https://proxy.golang.org/,direct
export GONOSUMDB='github.com/github/*'
export GONOPROXY=
export GOPRIVATE=

function agent() {
    if [[ -n $1 ]]
    then
        local sock=~/.ssh/sockets/agent-"$1"
        if [[ -S $sock ]]
        then
            export SSH_AUTH_SOCK=$sock
        else
            echo "$sock is not a socket"
            return 1
        fi
    fi
    if [[ $- == *i* ]]
    then
        echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
        ssh-add -l
    fi >&2
}

if [[ $USER = build && $HOME = /workspace ]]
then
    export GHE_DEV=t
    export PATH=~/enterprise2:$PATH
    agent gpg
fi

for rc in ~/.config/env.d/*
do
    source "$rc"
done

[[ -n $ZSH_NAME ]] && typeset -U path
