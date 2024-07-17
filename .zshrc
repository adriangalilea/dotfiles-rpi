# === User config ===

export EDITOR='hx'
export TZ='Europe/Madrid'
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"

# Directory stack options
setopt AUTO_PUSHD
setopt PUSHD_SILENT
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# disable "r" command (which runs previous executed command) 
disable r

# Path to your oh-my-zsh installation.

# export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to use case-sensitive completion.

CASE_SENSITIVE='false'

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.

HYPHEN_INSENSITIVE='false'

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="false"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"

HIST_STAMPS='yyyy-mm-dd'

# Commands starting from " " (whitespace) won't be saved in history:

HIST_IGNORE_SPACE='true'

# history file
HISTFILE=~/.zsh_history

# Number of lines kept in the history file
# HISTSIZE=10000

# Number of lines kept in the history list in memory
# SAVEHIST=10000

# Share history between all sessions

setopt SHARE_HISTORY

# Automatically save the history after each command

setopt INC_APPEND_HISTORY

# Don't overwrite old commands

setopt HIST_IGNORE_ALL_DUPS

# Share command history between terminal instances

setopt EXTENDED_HISTORY

# Record the timestamp for each command

setopt HIST_EXPIRE_DUPS_FIRST

# Sourcing the Oh-My-ZSH source:

# source "$ZSH/oh-my-zsh.sh"

# This PATH needs to be set before all other modifications:
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/.local/bin:$PATH"

# === Plugin management ===

source "$HOME/.zplugrc"


# === Shell parts ===

source "$HOME/.shell/.exports"
source "$HOME/.shell/.aliases"
source "$HOME/.shell/.functions"
source "$HOME/.shell/.external"
source "$HOME/.shell/.completions"
if [ -f "$HOME/.env" ]; then
  source "$HOME/.env"
fi


# Load the add-zsh-hook function
autoload -U add-zsh-hook

# Add the hook to call ls_after_cd after every directory change
add-zsh-hook chpwd files

files
