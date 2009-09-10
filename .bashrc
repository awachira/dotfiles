#
# Multiplatform bashrc for use on OS X and Linux (Debian or RedHat families)
#

# Set interactive flag; occasionally useful for turning stuff off, e.g. keychain
INTERACTIVE=`echo $- | grep i`


#
# Miscellaneous shell builtin tweaks
#

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS. (from Debian)
shopt -s checkwinsize

# Expand aliases; needed to use below alises via Vim :sh / :!
shopt -s expand_aliases

# Colors and color ls
case $( uname -s ) in
    Linux )
        eval `dircolors -b` # sets and exports LS_COLORS for bash terminals
        alias ls='ls --color=auto'
        ;;
    Darwin )
        export LSCOLORS="ExfxcxdxbxEgEdabagacad"
        alias ls='ls -G'
        ;;
esac



#
# Exports 
#

# General
export TERM="xterm-color"
export DISPLAY=:0.0
export EDITOR=vim

# MANPATH
ports_manpath=/opt/local/share/man
export MANPATH=$ports_manpath:$MANPATH

# PATH
ports_path=/opt/local/bin:/opt/local/sbin:/opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/
vmware_path=/Library/Application\ Support/VMWare\ Fusion
redhat_path=/sbin:/usr/sbin
ruby_path=/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin
local=/usr/local/bin:/usr/local/sbin
export PATH=$ports_path:$vmware_path:$redhat_path:$ruby_path:$local:$PATH


#
# Aliases
#

alias svim='sudo vim'
alias stail="sudo tail"
alias port="sudo port"
alias apt-get='sudo apt-get'
alias apt-cache='sudo apt-cache'
alias aptitude='sudo aptitude'
alias yum='sudo yum'
alias gem='sudo gem'
alias tree='tree -Ca -I ".git|*.pyc|*.swp"'
alias screen='TERM=screen screen'

# Apache reload alias
if [ -f /etc/init.d/apache2 ]; then
    apache=apache2
elif [ -f /etc/init.d/httpd ]; then
    apache=httpd
fi
alias rap="sudo /etc/init.d/$apache reload"

# Platform specific 'ps' alias
case $( uname -s) in
    Darwin )
        alias ps='ps -T'
        ;;
esac



#
# Tab completion
#

# MacPorts
if [ -f /opt/local/etc/bash_completion ]; then
    . /opt/local/etc/bash_completion
fi

# Debian
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi



#
# Colorized prompt, with different username colors for different systems.
#

# Color codes
RED='\[\033[01;31m\]'
GREEN='\[\033[01;32m\]'
YELLOW='\[\033[01;33m\]'
BLUE='\[\033[01;34m\]'
PURPLE='\[\033[01;35m\]'
CYAN='\[\033[01;36m\]'
WHITE='\[\033[01;37m\]'
NIL="\[\033[00m\]"

# Hostname styles
FULL='\H'
SHORT='\h'

# System => color/hostname map:
#   UC: username color
#   LC: location/cwd color
#   HD: hostname display (\h vs \H)
# Defaults:
UC=$GREEN
LC=$BLUE
HD=$FULL

# Manually cut hostname; hostname -s bails out on some systems.
case $( hostname | cut -d '.' -f 1 ) in
    jeff | ytram ) UC=$YELLOW LC=$GREEN ;;
    bitprophet ) UC=$CYAN ;;
    *-production ) UC=$RED HD=$SHORT ;;
    mail | code | bacula | www* | monitor | bender | xen ) UC=$RED ;;
esac

# Insert "lol git kinda sounds like 'get'" joke here
WTF=""
function _gb() {
    ref=$(git symbolic-ref HEAD 2>/dev/null) || return
    # goddammit why doesn't echo -e act the same as $PS1? :(
    echo -e " [\033[01;35m${ref#refs/heads/}\033[00m]"
}

# Prompt itself
PS1="${UC}\u@${HD}${NIL}:${LC}\w${NIL}\$(_gb) ${LC}\$${NIL} "



#
# Virtualenvwrapper support
#

# virtualenvwrapper
case $( uname -s ) in
    Darwin )
        # Leopard
        if [ `uname -r | cut -d '.' -f 1` == '9' ]; then
            virtualenvwrapper=/usr/local/bin/virtualenvwrapper_bashrc
        # Tiger
        else
            virtualenvwrapper=/opt/local/Library/Frameworks/Python.framework/Versions/2.5/bin/virtualenvwrapper_bashrc
        fi
        workon_home= # just use default ~/.virtualenvs
        ;;
    Linux )
        virtualenvwrapper=/usr/bin/virtualenvwrapper_bashrc
        # Relatively arbitrarily chose /opt/envs. Could also have gone with
        # /opt/virtualenvs perhaps.
        workon_home=/opt/envs
        ;;
esac
if [ -f $virtualenvwrapper  ]; then
    export WORKON_HOME=$workon_home
    source $virtualenvwrapper
fi



#
# Functions
#

function wwwify() {
    if [[ ! -a $1 ]]
    then
        echo "Need a filename to operate on."
        return 1
    fi

    if [[ -f /etc/redhat-release ]]
    then
        ug=apache
    else
        ug=www-data
    fi
    sudo chown -R $ug:$ug $1
    sudo chmod -R g+w $1
}


exclude="\.git|\.swp|\.coverage|\.pyc|_build"
function pgrep() {
    find . -maxdepth 1 -mindepth 1| egrep -v "$exclude" | xargs egrep -lir "$1" | egrep -v "$exclude"  | xargs egrep -Hin --color "$1"
}

function pvim() {
    vim -p `grep -lir "$1" . | egrep -v "$exclude"`
}
    



#
# System-specific local aliases and such
#

if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi
