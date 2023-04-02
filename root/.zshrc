# Path to your oh-my-zsh installation.
export ZSH="/root/.oh-my-zsh"
plugins=(git aws ansible terraform golang git-extras)

source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.profile ]] || source ~/.profile