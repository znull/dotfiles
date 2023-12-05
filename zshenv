#! /bin/zsh

if [[ -o login ]] || { [[ -n $BASH ]] && shopt -q login_shell }
then
    PATH_ORIG=$PATH
    PATH=

    for dir in \
        ~/bin \
        ~/.local/bin \
        ~/.cargo/bin \
        ~/go/bin \
        /workspaces/github/bin
    do
        [[ -d $dir ]] && PATH=$PATH${PATH:+:}$dir
    done

    PATH_PRIO=$PATH

    for dir in \
        "$GO_INSTALL_PATH" \
        /usr/local/sbin \
        /usr/local/bin \
        /sbin \
        /bin \
        /usr/sbin \
        /usr/bin
    do
        [[ -d $dir ]] && PATH=$PATH${PATH:+:}$dir
    done

    [[ -r /data/github/shell/bin/gh-environment ]] && source /data/github/shell/bin/gh-environment
    [[ -r ~/.config/path ]] && source ~/.config/path

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
fi

export DOTFILES_INIT_ENV=true
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
        [[ $? -ne 2 ]]  # 2 is "unable to contact the authentication agent"
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
