# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias build='./build.sh'
alias clean='./clean.sh'
alias prun='pin2 -t'
alias c=clear
alias chapel='source /shared/bin/chapel_setup.sh'
