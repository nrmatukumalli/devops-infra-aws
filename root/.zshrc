# Path to your oh-my-zsh installation.
export ZSH="/root/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git aliases themes aws ansible terraform golang git-extras)
source $ZSH/oh-my-zsh.sh

source /root/venv/bin/activate

alias ll='ls --color=never -l'
alias la='ls --color=never -la'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"

export PATH=$PATH:/usr/local/bin:/root/profile/