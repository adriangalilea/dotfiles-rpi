# This file is sourced for all shells, not just interactive ones like `.zshrc`.

# The intention is to keep the ~/.zshrc while moving history to ~/.local/state/zsh/history and zcompdump to ~/.local/cache/zsh/zcompdump-*

# Set XDG base directories if not already set
# XDG: A standard for organizing user directories for config, data, cache, and state files
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # User-specific configuration files
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # User-specific data files
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.local/cache}"       # Note the cache folder by XDG standards is: $HOME/.cache
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State files that should persist between application restarts

# ssh config dir
export SSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ssh/config"

# Zsh-specific configurations
export ZDOTDIR="$HOME"                                        # Keep .zshrc in the home directory
export HISTFILE="$XDG_STATE_HOME/zsh/history"                 # Store Zsh history in XDG state directory
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"  # Store completion dump file in XDG cache directory

# zplug configuration
export ZPLUG_RCFILE="${XDG_CONFIG_HOME}/zplug/zplugrc"        # zplug configuration file

# Set ZPLUG_HOME based on available locations
if [ -d "/opt/homebrew/opt/zplug" ]; then
    # macOS Homebrew installation
    export ZPLUG_HOME="/opt/homebrew/opt/zplug"
elif [ -d "${XDG_DATA_HOME}/zplug" ]; then
    # XDG compliant location
    export ZPLUG_HOME="${XDG_DATA_HOME}/zplug"
else
    # Default fallback
    export ZPLUG_HOME="${HOME}/.zplug"
fi

# Ensure ZPLUG_HOME exists
if [ ! -d "$ZPLUG_HOME" ]; then
    echo "Warning: ZPLUG_HOME directory does not exist: $ZPLUG_HOME"
    echo "You may need to install zplug or create this directory manually."
fi

export ZPLUG_RCFILE="${XDG_CONFIG_HOME:-$HOME/.config}/zplug/zplugrc"

# remove .terminfo from ~ 
# TODO figure out why this causes corruption in kitty ssh sessions
# export TERMINFO_DIRS="$XDG_STATE_HOME/.local/share/terminfo:/usr/share/terminfo"

# Ensure directories exist
mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME/zsh" "${ZSH_COMPDUMP:h}"

# Load fzf functions in non-interactive shells or when Zsh is the script interpreter
if [[ ! $- == *i* ]] || [[ "${0:t}" = "zsh" ]]; then
  # Ensure 'bat' command is available for fzf functions
  if ! command -v bat &> /dev/null; then
    if command -v batcat &> /dev/null; then
      alias bat=batcat
    else
      alias bat="cat"  # Fallback to 'cat' if neither 'bat' nor 'batcat' is available
    fi
  fi
  
  source "$HOME/.shell/fzf_functions.zsh"
fi
