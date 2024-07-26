# .zshrc

#┌─────────────────────────────────────────────────┐
#│               Completion System                 │
#└─────────────────────────────────────────────────┘
# Efficiently load completion system
autoload -Uz compinit
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
  compinit -d "$ZSH_COMPDUMP"
else
  compinit -C -d "$ZSH_COMPDUMP"
fi

#┌─────────────────────────────────────────────────┐
#│                     Core                        │
#└─────────────────────────────────────────────────┘
# --- Editor ---
export EDITOR="hx"  # Set default editor to helix

# --- Locale and Time ---
export LANG="en_US.UTF-8"        # Base locale: US English for number formatting
export LC_ALL="en_US.UTF-8"      # Set all locales to en_US.UTF-8 for consistency
export LANGUAGE="en_US"          # English
export LC_MESSAGES="en_US.UTF-8" # Ensure English for system messages
export TZ="Europe/Madrid"        # Set time zone to Madrid, Spain
export LC_NUMERIC="en_US.UTF-8"  # Ensure US-style number formatting

# Custom date format
export DATE_FORMAT="%Y/%m/%d"
export TIME_STYLE="+%Y/%m/%d"    # Custom time style for ls and other GNU utilities

# Note: To use the metric system, euro currency, and Spanish date formats,
# you may need to configure these on an application-by-application basis.

# --- Directory stack ---
setopt AUTO_PUSHD           # Automatically push dirs to stack
setopt PUSHD_SILENT         # Don't print dir stack after pushd/popd
setopt PUSHD_IGNORE_DUPS    # Don't push duplicate dirs
setopt PUSHD_MINUS          # Swap meaning of + and - for pushd

# --- History ---
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"  # History file location
export HISTORY_IGNORE="(ls|cd|salsa|la|ll|h|yy|l|pwd|exit|sudo reboot|history|cd -|cd ..)"  # Commands to ignore in history

HISTSIZE=10000              # Number of lines in history file
SAVEHIST=10000              # Number of lines in memory history
setopt SHARE_HISTORY        # Share history between sessions
setopt INC_APPEND_HISTORY   # Append to history file immediately
setopt HIST_IGNORE_ALL_DUPS # Don't save duplicate commands
setopt EXTENDED_HISTORY     # Save timestamp and duration of commands
setopt HIST_EXPIRE_DUPS_FIRST # Remove duplicates first when trimming history
setopt HIST_IGNORE_SPACE    # Don't save commands starting with space

#┌─────────────────────────────────────────────────┐
#│                  PATH Setup                     │
#└─────────────────────────────────────────────────┘
# Note: This section needs to be set before all other modifications
path=(
  "$HOME/.config/shell/utils"
  "$HOME/.config/shell/utils/dl"
  "/usr/local/sbin"
  "/usr/local/bin"
  "/usr/sbin"
  "/usr/bin"
  "/sbin"
  "/bin"
  "$HOME/.local/bin"
  $path
)
export PATH

#┌─────────────────────────────────────────────────┐
#│                     zplug                       │
#└─────────────────────────────────────────────────┘

# Run the zplug installer if ZPLUG_HOME does not exist
if [ ! -d "$ZPLUG_HOME" ]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

    # Check again if ZPLUG_HOME exists after running the installer
    if [ ! -d "$ZPLUG_HOME" ]; then
        echo "Warning: ZPLUG_HOME directory does not exist: $ZPLUG_HOME"
    fi
fi

source "$ZPLUG_RCFILE"

#┌─────────────────────────────────────────────────┐
#│               Shell Components                  │
#└─────────────────────────────────────────────────┘
source "$HOME/.config/shell/exports"     # Load custom exports
source "$HOME/.config/shell/aliases"     # Load custom aliases
source "$HOME/.config/shell/functions"   # Load custom functions
source "$HOME/.config/shell/external"    # Load external configurations
source "$HOME/.config/shell/completions" # Load custom completions

#┌─────────────────────────────────────────────────┐
#│            Environment Variables                │
#└─────────────────────────────────────────────────┘
[[ -f "$HOME/.env" ]] && source "$HOME/.env"  # Load .env file if it exists

#┌─────────────────────────────────────────────────┐
#│                   Zsh Hooks                     │
#└─────────────────────────────────────────────────┘
autoload -U add-zsh-hook              # Load the add-zsh-hook function
add-zsh-hook chpwd files              # Add hook to call files after every directory change

#┌─────────────────────────────────────────────────┐
#│               Color Settings                    │
#└─────────────────────────────────────────────────┘
# TODO: This is a patch for a zplug plugin that is not updated, this should be removed eventually.
unset GREP_COLOR
export GREP_COLORS="mt=1;35"

#┌─────────────────────────────────────────────────┐
#│               Initial Actions                   │
#└─────────────────────────────────────────────────┘
files  # List files when .zshrc loads

#┌─────────────────────────────────────────────────┐
#│                 Powerlevel10k                   │
#└─────────────────────────────────────────────────┘
# --- Instant prompt ---
# NOTE: It's so down here because it was complaining constantly.
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Configuration ---
[[ ! -f "${XDG_CONFIG_HOME:-$HOME/.config}/p10k/p10k.zsh" ]] || source "${XDG_CONFIG_HOME:-$HOME/.config}/p10k/p10k.zsh"
