# .zshenv: Sourced for all shells, including non-interactive ones
# Purpose: Set up environment variables and ensure XDG compliance.
# Note: There are some non-standard locations in favor of keeping ~ clean.
#       .ssh and other delicate folders are preserved against cleanliness for peace of mind.

#┌─────────────────────────────────────────────────┐
#│     XDG Base Directory Specification            │
#└─────────────────────────────────────────────────┘
# XDG: A standard for organizing user directories for config, data, cache, and state files
# More info: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"    # User-specific configuration files
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"   # User-specific data files
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State files that should persist between application restarts
# Note: This cache is in a non-standard location. The standard location is $HOME/.cache
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.local/cache}" # User-specific cache files

#┌─────────────────────────────────────────────────┐
#│                      Zsh                        │
#└─────────────────────────────────────────────────┘
export ZDOTDIR="$HOME"                                        # Keep .zshrc in the home directory
export HISTFILE="$XDG_STATE_HOME/zsh/history"                 # Store Zsh history in XDG state directory
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"  # Store completion dump file in XDG cache directory

#┌─────────────────────────────────────────────────┐
#│                     Misc                        │
#└─────────────────────────────────────────────────┘
# SSH configuration
export SSH_CONFIG="$XDG_CONFIG_HOME/ssh/config"

# Terminfo directories
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:$HOME/.terminfo:/usr/share/terminfo"

#┌─────────────────────────────────────────────────┐
#│                    zplug                        │
#└─────────────────────────────────────────────────┘
export ZPLUG_RCFILE="$XDG_CONFIG_HOME/zplug/zplugrc"
export ZPLUG_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zplug"

#┌─────────────────────────────────────────────────┐
#│       Ensure required directories exist         │
#└─────────────────────────────────────────────────┘
mkdir -p \
    "$XDG_CONFIG_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_CACHE_HOME" \
    "$XDG_STATE_HOME" \
    "$XDG_STATE_HOME/zsh" \
    "$XDG_CACHE_HOME/zsh" \
    "${ZSH_COMPDUMP:h}" \
    "$XDG_DATA_HOME/terminfo"

#┌─────────────────────────────────────────────────┐
#│       Load fzf functions for completions        │
#└─────────────────────────────────────────────────┘
# This section is necessary for the completions pane to have the correct
# functions loaded. Without this, these functions would not be available
# in the non-interactive shell that the completions runs in.
if [[ ! $- == *i* ]] || [[ "${0:t}" = "zsh" ]]; then
    # Ensure 'bat' command is available for fzf functions
    if ! command -v bat &> /dev/null; then
        if command -v batcat &> /dev/null; then
            alias bat=batcat
        else
            alias bat="cat"  # Fallback to 'cat' if neither 'bat' nor 'batcat' is available
        fi
    fi
    
    source "$HOME/.config/shell/fzf_functions.zsh"
fi
