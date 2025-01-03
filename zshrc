#! /bin/zsh

if [[ -z $GHE_DEV && $HOSTNAME = *.github.net ]]
then
    OLDLESS=$LESS
    source /etc/profile
    LESS=$OLDLESS
    unset OLDLESS
fi

if [[ $- = *i* && -z $DOTFILES_INIT_PROFILE ]] && command -v zsh > /dev/null
then
    # interactive shell without dotfiles login? re-exec login shell
    set -x
    export DOTFILES_INIT_PROFILE=true
    exec zsh -l
fi

alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias ci='git commit'
alias dus='du -sh *| sort -h'
alias gg='git sw'
alias grl='git remote | xargs git remote show -n'
alias issh="ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'loglevel error'"
alias sgit=git
alias st='git status -sb'
alias sv='sort | v'
alias v="$PAGER"
alias vj='bat -l json'
alias vd='git diff | vim -R -'
alias vp='vim -R -M -'
alias nz="tr '\n' '\0'"
alias zn="tr '\0' '\n'"
alias versions="nz | xargs -0 sha1sum | sort"

matches() {
    sz=$(stat -c '%s' "$1")
    csum=$(sha1sum "$1" | awk '{ print $1 }')
    find -type f -size ${sz}c -print0 | xargs -0 sha1sum | grep $csum
}

case "$OSTYPE" in
    darwin*)
        export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
        alias pidof='killall -d'
        alias locate=mdfind
        alias vi=vim
        alias ldd='otool -L'
        ;;

    linux*)
        alias pbcopy='xclip -sel clip'
        alias psl='ps -e f -o pid,stat,time,%cpu,wchan=WCHAN________________,command'
        alias open=xdg-open
        ;;
esac

if [[ -n $GHE_DEV ]]
then
    alias src="cd ~/enterprise2"
    alias r="src; chroot-stop.sh; chroot-reset.sh; sudo ./chroot-cluster-stop.sh; chroot-cluster-reset.sh test/cluster.conf; chroot-cluster-reset.sh test/cluster-ha.conf; chroot-cluster-reset.sh test/cluster-dr.conf; chroot-cluster-reset.sh test/cluster-dr-lite.conf;"
    alias b="src; r; chroot-build.sh"
    alias d="src; env -u GITHUB_HOSTNAME chroot-start.sh && chroot-configure.sh"
    alias bd="b && d"

    alias dc="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster.conf"
    alias bdc="b && dc"

    alias dha="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster-ha.conf"
    alias bdha="b && dha"

    alias dhaa="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster-ha-active.conf"
    alias bdhaa="b && dhaa"

    alias dhac="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster-ha-cache.conf"
    alias bdhac="b && dhac"

    alias dcdr="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster-dr.conf"
    alias bdcdr="b && dcdr"

    alias dcdrl="src; env -u GITHUB_HOSTNAME chroot-cluster-start.sh test/cluster-dr-lite.conf"
    alias bdcdrl="b && dcdrl"

    alias cip="chroot-cluster-ip.sh; chroot-ip.sh"
    alias sshc="chroot-ssh.sh"
    alias sshp="chroot-cluster-ssh.sh build-ha-primary"
    alias sshdrp="chroot-cluster-ssh.sh build-dr-primary-main"
    alias sshdrs="chroot-cluster-ssh.sh build-dr-secondary-main"
    alias sshr="chroot-cluster-ssh.sh build-ha-replica"
    alias sshr2="chroot-cluster-ssh.sh build-ha-replica2"
    alias sshd="chroot-cluster-ssh.sh build-cluster-data"
    alias ssha="chroot-cluster-ssh.sh build-cluster-app"
fi

if command -v dircolors > /dev/null
then
    eval `dircolors`
    export LS_COLORS="$LS_COLORS:ow=103;30;01"
    export LSOPT="$LSOPT --color"
fi
alias l="ls -CF $LSOPT"
alias ll="ls -la $LSOPT"
alias lo="ls -sh1 $LSOPT"

if [[ -n $ZSH_NAME ]]
then
    autoload -U zfinit zmv
    zfinit

    # completion
    setopt nobadpattern correct dvorak listpacked
    unsetopt nomatch

    DIRSTACKSIZE=8
    setopt autopushd pushdminus pushdsilent pushdtohome
    unsetopt autocd beep
    alias ds='echo "${dirstack[@]}"'
    cdpath=(~ ~/src)

    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_ALL_DUPS
    setopt HIST_IGNORE_SPACE
    setopt HIST_REDUCE_BLANKS
    setopt HIST_SAVE_NO_DUPS
    setopt INC_APPEND_HISTORY_TIME
    setopt EXTENDED_HISTORY
    HISTFILE=~/.histfile
    HISTSIZE=100000
    SAVEHIST=10000

    test -d "$HOMEBREW_PREFIX/share/zsh-completions" && fpath=($HOMEBREW_PREFIX/share/zsh-completions $fpath)
    test -d "$HOMEBREW_PREFIX/share/zsh/site-functions" && fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

    # The following lines were added by compinstall
    zstyle ':completion:*' completer _complete _correct
    zstyle ':completion:*' format 'completions of type: %d'
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' list-colors ''
    zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
    zstyle ':completion:*' matcher-list ''
    zstyle ':completion:*' max-errors 1
    zstyle ':completion:*' menu select=1
    zstyle ':completion:*' prompt 'corrections (%e errors) >'
    zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    zstyle ':completion:*' verbose true
    zstyle :compinstall filename ~/.zshrc

    autoload -Uz compinit
    compinit -i
    # End of lines added by compinstall

    compdef mosh=ssh
    compdef msh=ssh
    compdef tsh=ssh
    compdef sshfs=scp

    # use vi line editing
    KEYTIMEOUT=20
    bindkey -v

    # create a zkbd compatible hash;
    # to add other keys to this hash, see: man 5 terminfo
    typeset -A key

    key[Home]=${terminfo[khome]}

    key[End]=${terminfo[kend]}
    key[Insert]=${terminfo[kich1]}
    key[Delete]=${terminfo[kdch1]}
    key[Up]=${terminfo[kcuu1]}
    key[Down]=${terminfo[kcud1]}
    key[Left]=${terminfo[kcub1]}
    key[Right]=${terminfo[kcuf1]}
    key[PageUp]=${terminfo[kpp]}
    key[PageDown]=${terminfo[knp]}

    # setup key accordingly
    [[ -n "${key[Home]}"     ]] && bindkey "${key[Home]}"     vi-beginning-of-line
    [[ -n "${key[End]}"      ]] && bindkey "${key[End]}"      vi-end-of-line
    [[ -n "${key[Insert]}"   ]] && bindkey "${key[Insert]}"   vi-overwrite-mode
    [[ -n "${key[Delete]}"   ]] && bindkey "${key[Delete]}"   vi-delete-char
    [[ -n "${key[Up]}"       ]] && bindkey "${key[Up]}"       up-line-or-history
    [[ -n "${key[Down]}"     ]] && bindkey "${key[Down]}"     down-line-or-history
    [[ -n "${key[Left]}"     ]] && bindkey "${key[Left]}"     vi-backward-char
    [[ -n "${key[Right]}"    ]] && bindkey "${key[Right]}"    vi-forward-char
    [[ -n "${key[PageUp]}"   ]] && bindkey "${key[PageUp]}"   beginning-of-buffer-or-history
    [[ -n "${key[PageDown]}" ]] && bindkey "${key[PageDown]}" end-of-buffer-or-history

    # command mode
    bindkey -a '\e[2~' vi-insert
    bindkey -a d vi-backward-char
    bindkey -a n vi-forward-char
    bindkey -a t up-line-or-history
    bindkey -a h down-line-or-history
    bindkey -a e vi-delete
    bindkey -a l vi-repeat-search
    bindkey -a q push-line-or-edit
    [[ -n "${key[PageUp]}"   ]] && bindkey -a "${key[PageUp]}"   beginning-of-buffer-or-history
    [[ -n "${key[PageDown]}" ]] && bindkey -a "${key[PageDown]}" end-of-buffer-or-history

    # insert mode
    bindkey '^t' vi-indent
    bindkey '\e[2~' vi-cmd-mode
    #bindkey '\e[1~' vi-beginning-of-line
    #bindkey '\eOH' vi-beginning-of-line
    bindkey '^a' vi-beginning-of-line
    #bindkey '\e[4~' vi-end-of-line
    #bindkey '\eOF' vi-end-of-line
    bindkey '^e' vi-end-of-line
    #bindkey '\e[3~' vi-delete-char
    #bindkey '\e[A' up-line-or-history
    #bindkey '\e[B' down-line-or-history
    #bindkey '\e[C' vi-forward-char
    #bindkey '\e[D' vi-backward-char
    #bindkey '\eOA' up-line-or-history
    #bindkey '\eOB' down-line-or-history
    #bindkey '\eOC' vi-forward-char
    #bindkey '\eOD' vi-backward-char

    #bindkey -a '\e[5~' beginning-of-history
    #bindkey -a '\e[6~' end-of-history
    #bindkey '\e[5~' beginning-of-history
    #bindkey '\e[6~' end-of-history

    bindkey -a / history-incremental-search-backward
    bindkey '^h' run-help
    bindkey '^n' history-search-backward
    bindkey '^p' history-beginning-search-backward
    bindkey '^r' history-incremental-search-backward
    bindkey '^\n' accept-and-infer-next-history
    bindkey '^[^M' self-insert-unmeta

    bindkey '^z' undo
    bindkey -a u undo
    bindkey -a '^r' redo

    autoload -z edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd v edit-command-line

    if [ -f "$HOME/.ssh/known_hosts" ]
    then
        hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
        zstyle ':completion:*:hosts' hosts $hosts
    fi

    command -v kubectl > /dev/null && source <(kubectl completion zsh)
fi

# fzf completion
if [[ -n $ZSH_NAME ]]
then
   [[ $- == *i* ]] && source ~/.dotfiles/vim/pack/plugin/start/fzf/shell/completion.zsh
    source ~/.dotfiles/vim/pack/plugin/start/fzf/shell/key-bindings.zsh
elif [ -n "$BASH_VERSION" ]
then
    [[ $- == *i* ]] && source ~/.dotfiles/vim/pack/plugin/start/fzf/shell/completion.bash
    source ~/.dotfiles/vim/pack/plugin/start/fzf/shell/key-bindings.bash
fi

[[ -s ~/.nvm/nvm.sh ]] && source ~/.nvm/nvm.sh
[[ -n $PATH_ORIG && -n $NVM_BIN ]] && PATH_PRIO=$PATH_PRIO:$NVM_BIN
[[ -s $NVM_DIR/bash_completion ]] && source "$NVM_DIR/bash_completion"

[[ -n $ZSH_NAME ]] && command -v rbenv > /dev/null && eval "$(rbenv init -)"

function akfp() {
    local ak=${1:-~/.ssh/authorized_keys}
    while read l
    do
        [[ -n $l && ${l###} = $l ]] && ssh-keygen -l -f /dev/stdin <<<$l
    done < "$ak"
}

function color() {
    if [[ $1 = '-p' ]]
    then
        if [[ -n $ZSH_NAME ]]
        then
            esc_open='%{'
            esc_close='%}'
        else
            esc_open='\['
            esc_close='\]'
        fi
        shift
    fi

    case "$1" in
        none) echo -ne $esc_open'\033[0m'$esc_close ;;
        black) echo -ne $esc_open'\033[0;30m'$esc_close ;;
        blue) echo -ne $esc_open'\033[0;34m'$esc_close ;;
        brown) echo -ne $esc_open'\033[0;33m'$esc_close ;;
        cyan) echo -ne $esc_open'\033[0;36m'$esc_close ;;
        grey) echo -ne $esc_open'\033[1;30m'$esc_close ;;
        green) echo -ne $esc_open'\033[0;32m'$esc_close ;;
        lightgrey) echo -ne $esc_open'\033[0;37m'$esc_close ;;
        lightblue) echo -ne $esc_open'\033[1;34m'$esc_close ;;
        lightcyan) echo -ne $esc_open'\033[1;36m'$esc_close ;;
        lightgreen) echo -ne $esc_open'\033[1;32m'$esc_close ;;
        lightpurple) echo -ne $esc_open'\033[1;35m'$esc_close ;;
        lightred) echo -ne $esc_open'\033[1;31m'$esc_close ;;
        purple) echo -ne $esc_open'\033[0;35m'$esc_close ;;
        red) echo -ne $esc_open'\033[0;31m'$esc_close ;;
        white) echo -ne $esc_open'\033[1;37m'$esc_close ;;
        yellow) echo -ne $esc_open'\033[1;33m'$esc_close ;;
        all|show|*)
                for c in black blue brown cyan grey green lightblue \
                    lightcyan lightgreen lightgrey lightpurple lightred purple \
                    red white yellow
                do
                    color $c
                    echo $c
                done
                color none
        ;;
    esac
}

function dockrm() {
    docker ps -a |
        tail -n +2 |
        awk '{ print $NF }' |
        fzf --multi --height 10 |
        xargs --no-run-if-empty \
            docker rm
}

function f() {
    if [ "$HOSTTYPE" = FreeBSD ]
    then
        local po=-print
    else
        local po=-printf
        local format='%P\n'
    fi

    case $# in
        1)
            find . -name .svn -prune \
                -o -name .idea -prune \
                -o -name .metadata -prune \
                -o -name node_modules -prune \
                -o -regex '.*/\.git/\(objects\|packed-refs\|refs\|logs\)' -prune \
                -o -regex '.*/target\(-eclipse\)?' -prune \
                -o -iname "*$1*" $po $format
        ;;

        2)
            find "$1" -name .svn -prune -o -iname "*$2*" $po $format
        ;;

        *)
            echo 'usage: f [dir] <stem>'
        ;;
    esac
}

function fa() {
    find . -iname "*$1*"
}

function gh_token() {
    gh config get --host github.com oauth_token
}

function hl() {
    pattern=$1
    shift
    grep --color=always "$@" -E "$pattern|$"
}

function msh() {
    local host=$1
    shift
    local mo

    case $host in
        ??)
            host=$host.databack.com
            set -- "$@" 'zsh -l'
            ;;

        aplex|*@aplex|*.*|*) ;;
    esac

    mosh $mo "$host" -- tmux -2 new-session -AD -slunz "$@"
}

function oports() {
    case "$OSTYPE" in
        linux*)
            netstat -utlp "$@" | sed \
                -e 's/ PID\/Program name/PID\/name/' \
                -e 's/   \([^ ]\+\) *$/\1/'
        ;;

        *|darwin*|FreeBSD*)
            if command -v lsof > /dev/null
            then
                    sudo lsof -i udp "$@"
                    sudo lsof -i tcp -s tcp:listen "$@"
            else
                    netstat -p udp -a
                    netstat -p tcp -a | grep LISTEN
            fi
        ;;
    esac
}

function osc52() {
    echo -en "\x1b]52;c;$(base64)\x07"
}

function tsh() {
    local host=$1
    shift
    ssh -t "$host" -- "tmux -2 new-session -AD -slunz $@"
}

function wanip() {
    echo -n 'A: '; curl -s -m 4 https://checkip.amazonaws.com
    echo -n 'A: '; dig +short myip.opendns.com @resolver1.opendns.com || echo
    echo -n 'AAAA: '; dig +short myip.opendns.com aaaa @resolver1.opendns.com || echo
    echo -n 'AAAA: '; dig -6 +short myip.opendns.com aaaa @resolver1.opendns.com || echo
}

if command -v color > /dev/null
then
    CNONE="$(color none)"
    CPNONE="$(color -p none)"

    if [[ -n $PROMPT_COLOR ]]
    then
        HCOLOR=$(color -p "$PROMPT_COLOR")
        PCHCOLOR=$(color "$PROMPT_COLOR")
    else
        HCOLOR=$(color -p white)
        PCHCOLOR=$(color white)
    fi
    RCOLOR="$HCOLOR"
    if [ "$LOGNAME" = root ]
    then
        PCHCOLOR=$(color lightgrey)
        RCOLOR=$(color -p lightgrey)
    else
        unset HCOLOR
    fi
fi

test -r /etc/debian_chroot && unset LS_COLORS

test "$STY" && PCHROOT="$STY"
test -r /etc/debian_chroot && PCHROOT="$(cat /etc/debian_chroot)"
test "$PCHROOT" && TCHROOT="[${PCHROOT}]"
test "$PCHROOT" && PCHROOT="[${CPNONE}${PCHROOT}$RCOLOR]"
if [[ -n $GH_ENV ]]
then
    GH_SITE=${HOSTNAME#*.}
    GH_SITE=${GH_SITE%%.*}
fi

if [[ -n $ZSH_NAME ]]
then
    # zshmisc - PS1 docs
    # zshcontrib - vcs_info docs
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git hg svn
    zstyle ':vcs_info:*' check-for-changes true
    #zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]'
    #zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]'
    #zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
    zstyle ':vcs_info:*' actionformats "[%F{white}%s$RCOLOR:%F{white}%m%u%c%$RCOLOR:%F{white}%b|%a$RCOLOR]"
    zstyle ':vcs_info:*' formats "[%F{white}%s$RCOLOR:%F{white}%m%u%c%$RCOLOR:%F{white}%b$RCOLOR]"
    precmd() {
        vcs_info
        local host_label=${CODESPACE_NAME:-%m}${GH_SITE:+.$GH_SITE}
        PROMPT="$RCOLOR"'['"${HCOLOR}${host_label}${RCOLOR}]${PROMPT_EXTRA}"'[%D{%f.%m}•%T]'"$PCHROOT${vcs_info_msg_0_}(%?)%(1j. |${jobtexts%% *}|.)%(!. #.❯)$CPNONE "      # ➤ • ❯
    }

    dirhide() {
        unset RPROMPT
    }
    dirshow() {
        RPROMPT=$RCOLOR%~$CPNONE
    }
    dirshow

else
    export PS1="$RCOLOR"'['"$HCOLOR"'\h'"$RCOLOR]$PCHROOT"'($?)➤'"$CPNONE"' '
    unset HCOLOR PCHCOLOR CNONE CPNONE RCOLOR PCHROOT
fi

for rc in ~/.config/rc.d/*
do
    source "$rc"
done

# vim: sw=4 et
