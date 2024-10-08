#! /bin/zsh

path_debug() {
    echo "== $@" >&2
    tr : '\n' <<<"$PATH" >&2
    echo >&2
}

if [[ -o login ]] || ( [[ -n $BASH ]] && shopt -q login_shell )
then
    PATH_ORIG=$PATH
    PATH=

    for dir in \
        ~/.rbenv/shims \
        ~/bin \
        ~/.local/bin \
        ~/.cargo/bin \
        /workspaces/github/vendor/gitrpcd/build \
        ~/go/bin \
        $(~/.config/path-prio 2>/dev/null)
    do
        [[ -d $dir ]] && PATH=$PATH${PATH:+:}$dir
    done

    PATH_PRIO=$PATH

    for dir in \
        "$GO_INSTALL_PATH" \
        /usr/local/sbin \
        ~/bin/brew \
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
        if [[ -e /workspaces/.codespaces/.persistedshare/creation.log ]]
        then
            timeout 2m tail -f /workspaces/.codespaces/.persistedshare/creation.log | sed '/Finished configuring codespace/ q'
        fi
        [[ -z $LANG ]] && export LANG=C.utf-8
        export BROWSER=browser
        if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]
        then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv | sed -e 's/export PATH=/export PATH_LINUXBREW=/')"
            [[ -n "$PATH_LINUXBREW" ]] && PATH=$PATH:$PATH_LINUXBREW
        fi
        export HOMEBREW_NO_INSTALL_CLEANUP=1
    fi

    # after PATH_DOTFILES is set, we assume $PATH will be overwritten or
    # modified, and restore it (keeping changes) in .zlogin
    PATH_DOTFILES=$PATH:$PATH_ORIG
    PATH=$PATH_DOTFILES

    # like this, for example:
    [[ -r /workspaces/.codespaces/shared/.env ]] &&
        source <(perl -ne "next unless /^[^'=]+=[^']+$/; s/^/export /; s/=/='/; s/$/'/; print" < /workspaces/.codespaces/shared/.env)

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
export MANPAGER=manpager
export MANROFFOPT=-c
[[ $- = *i* ]] && export MOSH_ESCAPE_KEY=$(echo -e '\x1c')        # fixes C-^ switching in vim
export PYTHONSTARTUP=~/.pythonrc
export TZ_LIST='America/Los_Angeles;America/Denver;America/Chicago;America/New_York;UTC;Europe/London' #;Europe/Berlin
export UNAME=$(uname)

if command -v bat > /dev/null
then
    export PAGER=bat
else
    export PAGER=less
fi

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
