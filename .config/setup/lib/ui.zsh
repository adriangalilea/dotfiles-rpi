#!/bin/zsh

# Function to update the static line
update_static_line() {
    local message=$1
    echo -e "\033[1A\033[K$message"
}

run_with_spinner() {
    local title=$1
    shift

    if [[ $DEBUG == 1 ]]; then
        $*
    else
        # Run with spinner
        gum spin --spinner dot --title "$title" --show-output -- zsh -c "
            source_files() {
                for file in \"\$1\"/*; do
                    if [[ -f \"\$file\" ]]; then
                        source \"\$file\"
                    elif [[ -d \"\$file\" ]]; then
                        source_files \"\$file\"
                    fi
                done
            }
            source_files /home/adrian/.config/setup/installers
            $*
        "
    fi
}

# Single logging function that handles initialization and logging
log() {
  local log_message="$1"
  local log_level="${2:-info}"
  local log_section="${3:-${funcstack[2]:-}}"

  # Initialize if not already done and debug is enabled
  if [[ -z "$LOG_INITIALIZED" ]]; then
    if [[ "$DEBUG" -eq 1 ]]; then
      local script_path="${0:A}"
      gum log --level debug --time "15:04:05" "Executed by $USER" --prefix="$script_path"
    fi
    LOG_INITIALIZED=1
    echo
  fi

  # Handle debug level logging
  if [[ "$log_level" == "debug" && "$DEBUG" -ne 1 ]]; then
    return
  fi

  # Validate log level
  local valid_levels=(none debug info warn error fatal)
  if [[ ! " ${valid_levels[*]} " =~ " ${log_level} " ]]; then
    log_level="error"
    log_message="Invalid log level for message: ${log_message}. USE: ${valid_levels[*]}"
  fi

  local prefix_arg=""
  [[ -n "$log_section" ]] && prefix_arg="--prefix=$log_section"

  gum log --level "$log_level" --time "15:04:05" $prefix_arg "$log_message"
}

