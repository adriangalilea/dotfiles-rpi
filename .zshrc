# === user config ===

# --- mac specific area ---
# TODO there's no need for this and I should likely use p10k on every system anyway
# Check if the operating system is macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
  export ZPLUG_HOME=/opt/homebrew/opt/zplug
  source $ZPLUG_HOME/init.zsh

  # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
  # Initialization code that may require console input (password prompts, [y/n]
  # confirmations, etc.) must go above this block; everything else may go below.
  if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
  fi

  # Path to your oh-my-zsh installation.
  export ZSH="$HOME/.oh-my-zsh"

  ZSH_THEME="powerlevel10k/powerlevel10k"

  source $ZSH/oh-my-zsh.sh

  # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
  [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

fi

# --- editor ---

export EDITOR="hx"                     # set default editor to helix

# --- locale and time ---
export LANG="en_US.UTF-8"              # base locale: US english for number formatting
export LC_ALL="en_US.UTF-8"            # set all locales to en_US.UTF-8 for consistency
export LANGUAGE="en_US"                # english
export LC_MESSAGES="en_US.UTF-8"       # ensure English for system messages
export TZ="Europe/Madrid"              # set time zone to Madrid, Spain

# Custom date format
export DATE_FORMAT="%Y/%m/%d"

# Additional settings that won't cause locale errors
export LC_NUMERIC="en_US.UTF-8"        # ensure US-style number formatting
export TIME_STYLE="+%Y/%m/%d"          # custom time style for ls and other GNU utilities

# Note: To use the metric system, euro currency, and Spanish date formats,
# you may need to configure these on an application-by-application basis.

# --- directory stack ---

setopt AUTO_PUSHD                      # automatically push dirs to stack
setopt PUSHD_SILENT                    # don't print dir stack after pushd/popd
setopt PUSHD_IGNORE_DUPS               # don't push duplicate dirs
setopt PUSHD_MINUS                     # swap meaning of + and - for pushd

# --- completion ---

disable r                              # disable 'r' command (runs previous command)
CASE_SENSITIVE="false"                 # case-insensitive completion
HYPHEN_INSENSITIVE="false"             # treat hyphens and underscores as different

# --- history settings ---

export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"  # commands to ignore in history
HIST_STAMPS="yyyy/mm/dd"               # set history timestamp format
HIST_IGNORE_SPACE="true"               # don't save commands starting with space
HISTFILE=~/.zsh_history                # history file location
HISTSIZE=10000                         # number of lines in history file
SAVEHIST=10000                         # number of lines in memory history
setopt SHARE_HISTORY                   # share history between sessions
setopt INC_APPEND_HISTORY              # append to history file immediately
setopt HIST_IGNORE_ALL_DUPS            # don't save duplicate commands
setopt EXTENDED_HISTORY                # save timestamp and duration of commands
setopt HIST_EXPIRE_DUPS_FIRST          # remove duplicates first when trimming history

# --- path ---

# this section needs to be set before all other modifications
if [ -d "$HOME/.shell/utils" ] ; then PATH="$HOME/.shell/utils:$PATH" ; fi  # bespoke CLI utils
if [ -d "$HOME/.shell/utils/dl" ] ; then PATH="$HOME/.shell/utils/dl:$PATH" ; fi  # bespoke CLI utils
if [ -d "/usr/local/sbin" ] ; then PATH="/usr/local/sbin:$PATH" ; fi
if [ -d "/usr/local/bin" ] ; then PATH="/usr/local/bin:$PATH" ; fi
if [ -d "/usr/sbin" ] ; then PATH="/usr/sbin:$PATH" ; fi
if [ -d "/usr/bin" ] ; then PATH="/usr/bin:$PATH" ; fi
if [ -d "/sbin" ] ; then PATH="/sbin:$PATH" ; fi
if [ -d "/bin" ] ; then PATH="/bin:$PATH" ; fi
if [ -d "$HOME/.local/bin" ] ; then PATH="$HOME/.local/bin:$PATH" ; fi

# === plugin management ===

source "$HOME/.zplugrc"                # load plugin manager configuration

# === shell parts ===

source "$HOME/.shell/exports"         # load custom exports
source "$HOME/.shell/aliases"         # load custom aliases
source "$HOME/.shell/functions"       # load custom functions
source "$HOME/.shell/external"        # load external configurations
source "$HOME/.shell/completions"     # load custom completions

# --- environment variables ---

if [ -f "$HOME/.env" ]; then           # load .env file if it exists
  source "$HOME/.env"
fi

# --- zsh hooks ---

autoload -U add-zsh-hook               # load the add-zsh-hook function
add-zsh-hook chpwd files               # add hook to call files after every directory change

# --- color settings ---
# TODO this is a patch for a zplug plugin that is not updated, this should be removed eventually.

unset GREP_COLOR
export GREP_COLORS="mt=1;35"

# --- initial actions ---

files                                  # list files when .zshrc loads
