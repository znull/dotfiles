#! /bin/zsh

alias ....='cd ../../..'
alias ...='cd ../..'
alias ..='cd ..'
alias agp='ag --pager less '
alias dus='du -sh *| sort -h'
alias dv='export DVORAK=true'
alias gg='git sw'
alias grl='git remote | xargs git remote show -n'
alias issh="ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -o 'loglevel error'"
alias l="ls -CF $LSOPT"
alias la='echo "did you mean \"ll\"?"'
alias ll="ls -la $LSOPT"
alias lo="ls -sh1 $LSOPT"
alias sv='sort | v'
alias svlog='slog -v '
alias v="$PAGER"
alias vp='vim -R -M -'

case "$OSTYPE" in
    darwin*)
        export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
        alias pidof='killall -d'
        alias truecrypt='/Applications/TrueCrypt.app/Contents/MacOS/Truecrypt --text'
        alias locate=mdfind
        alias vi=vim
        alias cpkey='pbcopy < ~/.ssh/id_ed25519.pub && echo "copied id_ed25519.pub to clipboard"'
        alias ldd='otool -L'
        ;;

    linux*)
        alias pbcopy='xclip -sel clip'
        alias psl='ps -e f -o pid,stat,time,%cpu,wchan=WCHAN________________,command'
        alias open=xdg-open
        ;;
esac

if command -v dircolors > /dev/null
then
    eval `dircolors`
    export LSOPT="$LSOPT --color"
fi

if [[ -n $ZSH_NAME ]]
then
    cdpath=(~ ~/src)

    autoload -U zfinit zmv
    zfinit
    setopt nobadpattern correct dvorak incappendhistory listpacked
    unsetopt nomatch

    DIRSTACKSIZE=8
    setopt autopushd pushdminus pushdsilent pushdtohome

    test -d /usr/local/share/zsh-completions && fpath=(/usr/local/share/zsh-completions $fpath)

    # Lines configured by zsh-newuser-install
    HISTFILE=~/.histfile
    HISTSIZE=1000
    SAVEHIST=1000
    unsetopt autocd beep
    # End of lines configured by zsh-newuser-install

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
fi

# fzf completion
if [[ -n $ZSH_NAME ]]
then
    [[ $- == *i* ]] && source ~/.root/etc/vim/bundle/fzf/shell/completion.zsh
    source ~/.root/etc/vim/bundle/fzf/shell/key-bindings.zsh
elif [ -n "$BASH_VERSION" ]
then
    [[ $- == *i* ]] && source ~/.root/etc/vim/bundle/fzf/shell/completion.bash
    source ~/.root/etc/vim/bundle/fzf/shell/key-bindings.bash
fi

if [[ -n $ZSH_NAME ]] && command -v rbenv > /dev/null
then
    eval "$(rbenv init -)"
fi

if command -v color > /dev/null
then
    CNONE="$(color none)"
    CPNONE="$(color -p none)"

    if [ -r $HOME/.root/local/etc/pcolor ]
    then
        HCOLOR=$(color -p $(cat $HOME/.root/local/etc/pcolor))
        PCHCOLOR=$(color $(cat $HOME/.root/local/etc/pcolor))
    else
        HCOLOR=$(color -p white)
        PCHCOLOR=$(color white)
    fi
    RCOLOR="$HCOLOR"
    if [ "$LOGNAME" = root ]
    then
        PCHCOLOR=$(color grey)
        RCOLOR=$(color -p grey)
    else
        unset HCOLOR
    fi
fi

test -r /etc/debian_chroot && unset LS_COLORS

test "$STY" && PCHROOT="$STY"
test -r /etc/debian_chroot && PCHROOT="$(cat /etc/debian_chroot)"
test "$PCHROOT" && TCHROOT="[${PCHROOT}]"
test "$PCHROOT" && PCHROOT="[${CPNONE}${PCHROOT}$RCOLOR]"
if [[ -n $ZSH_NAME ]]
then
    # zshmisc - PS1 docs
    # zshcontrib - vcs_info docs
    setopt prompt_subst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git hg svn
    zstyle ':vcs_info:*' check-for-changes true
    #zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]'
    #zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]'
    #zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
    zstyle ':vcs_info:*' actionformats "[%F{white}%s$RCOLOR:%F{white}%m%u%c%$RCOLOR:%F{white}%b|%a$RCOLOR]"
    zstyle ':vcs_info:*' formats "[%F{white}%s$RCOLOR:%F{white}%m%u%c%$RCOLOR:%F{white}%b$RCOLOR]"
    VCSINFO='${vcs_info_msg_0_}'

    # ➤•❯ #
    PROMPT="$RCOLOR"'['"$HCOLOR%m$RCOLOR]$PCHROOT$VCSINFO"'(%?)%(1j. |${jobtexts%% *}|.)%(!. #.➤)'"$CPNONE "
    RPROMPT="$RCOLOR%~$CPNONE"

    function dirhide () {
        RPROMPT_backup=$RPROMPT
        unset RPROMPT
    }
    function dirshow () {
        RPROMPT=$RPROMPT_backup
        unset RPROMPT_backup
    }
else
    export PS1="$RCOLOR"'['"$HCOLOR"'\h'"$RCOLOR]$PCHROOT"'($?)➤'"$CPNONE"' '
fi

unset HCOLOR PCHCOLOR CNONE CPNONE RCOLOR PCHROOT VCSINFO

function akfp() {
    local ak=${1:-~/.ssh/authorized_keys}
    while read l
    do
        [[ -n $l && ${l###} = $l ]] && ssh-keygen -l -f /dev/stdin <<<$l
    done < "$ak"
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

function msh() {
    local host=$1
    shift
    local mo

    case $host in
        aplex|*@aplex|*.*) ;;

        ??)
            host=$host.databack.com
            set -- "$@" 'zsh -l'
            ;;

        # using --experimental-remote-ip=remote has the side-effect of allowing
        # CanonicalizeHostname to work when connecting
        *) mo=--experimental-remote-ip=remote ;;
    esac

    mosh $mo "$host" -- tmux -2 new-session -AD -slunz "$@"
}

function tsh() {
    local host=$1
    shift
    ssh -t -S none "$host" -- "test -n \"\$SSH_AUTH_SOCK\" && echo \"\$SSH_AUTH_SOCK\" >> ~/.ssh/agents; tmux -2 new-session -AD -slunz $@"
}

function wanip() {
    {
        dig +short myip.opendns.com @resolver1.opendns.com
        dig +short myip.opendns.com aaaa @resolver1.opendns.com
        dig -6 +short myip.opendns.com aaaa @resolver1.opendns.com
    } | sort -u
}

# vim: sw=4 et
