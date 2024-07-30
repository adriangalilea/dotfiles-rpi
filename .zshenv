# .zshenv: Sourced for all shells, including non-interactive ones
# Purpose: Set up environment variables and ensure XDG compliance.
# Note: There are some non-standard locations in favor of keeping ~ clean.
#       .ssh and other delicate folders are preserved against cleanliness for peace of mind.

#┌─────────────────────────────────────────────────┐
#│     XDG Base Directory Specification            │
#└─────────────────────────────────────────────────┘
# XDG: A standard for organizing user directories for config, data, cache, and state files
# More info: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

eval "$(/usr/local/bin/xdg-dirs)"

# custom go program (xdg_user_dirs_update_cross)(https://github.com/adriangalilea/xdg-user-dirs-update-cross)

#┌─────────────────────────────────────────────────┐
#│                      Zsh                        │
#└─────────────────────────────────────────────────┘
export ZDOTDIR="$HOME"                                        # Keep .zshrc in the home directory
export HISTFILE="$XDG_STATE_HOME/zsh/history"                 # Store Zsh history in XDG state directory
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"  # Store completion dump file in XDG cache directory
mkdir -p \
    "$XDG_STATE_HOME/zsh" \
    "$XDG_CACHE_HOME/zsh" \
    "${ZSH_COMPDUMP:h}" 

#┌─────────────────────────────────────────────────┐
#│                     Misc                        │
#└─────────────────────────────────────────────────┘
# SSH configuration
export SSH_CONFIG="$XDG_CONFIG_HOME/ssh/config"

# Terminfo directories
export TERMINFO_DIRS="$XDG_DATA_HOME/terminfo:$HOME/.terminfo:/usr/share/terminfo"
mkdir -p "$XDG_DATA_HOME/terminfo"

#┌─────────────────────────────────────────────────┐
#│                    zplug                        │
#└─────────────────────────────────────────────────┘
export ZPLUG_RCFILE="$XDG_CONFIG_HOME/zplug/zplugrc"
export ZPLUG_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zplug"

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
