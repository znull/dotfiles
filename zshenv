#! /bin/zsh

setup_PATH() {
    unset PATH

    for dir in \
        ~/bin \
        ~/.cargo/bin \
        /usr/local/opt/coreutils/libexec/gnubin \
        /usr/local/opt/findutils/libexec/gnubin \
        /usr/local/sbin \
        /usr/local/bin \
        /sbin \
        /bin \
        /usr/sbin \
        /usr/bin \
        '/Applications/VMware Fusion.app/Contents/Public'
    do
        if [[ -d $dir ]]
        then
            [[ -n $PATH ]] && PATH=$PATH:
            PATH=$PATH$dir
        fi
    done

    export PATH
}

setup_PATH

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
export MOSH_ESCAPE_KEY=$(echo -e '\x1c')        # fixes C-^ switching in vim
export PAGER=less
export PYTHONSTARTUP=~/.pythonrc
export TZ_LIST=America/Los_Angeles,America/Chicago,America/New_York,UTC,Europe/London,Europe/Berlin
export UNAME=$(uname)

for rc in ~/.config/env.d/*
do
    source "$rc"
done
