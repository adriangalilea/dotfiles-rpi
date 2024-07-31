#!/bin/zsh

# Global variables
JSON_CONFIG_PATH="/tmp/install_config.json"

# Function to generate JSON from CUE
generate_json_from_cue() {
    local cue_file="$1"

    if ! command -v cue &> /dev/null; then
        log "Error: 'cue' command not found. Please install CUE." error
        return 1
    fi

    log "Exporting CUE to JSON: $cue_file -> $JSON_CONFIG_PATH" debug
    if ! cue export "$cue_file" --out json > "$JSON_CONFIG_PATH"; then
        log "Error: Failed to generate JSON from CUE file." error
        log "CUE file contents:" debug
        cat "$cue_file" >&2
        return 1
    fi

    log "Successfully generated JSON from CUE" info
}

# Function to parse the configuration
parse_config() {
    local json_file="$1"
    jq -c '.steps[]' "$json_file"
}

# Function to validate a step
validate_step() {
    local step="$1"
    local step_type=$(echo "$step" | jq -r 'keys[0]')
    local content=$(echo "$step" | jq -r ".$step_type.content")

    case "$step_type" in
        apt|pipx|command)
            if [[ -z $(echo "$content" | jq -r '.[]') ]]; then
                log "Error: No content specified for $step_type step" error
                return 1
            fi
            ;;
        github)
            if [[ -z $(echo "$content" | jq -r '.[]') ]]; then
                log "Error: No repositories specified for github step" error
                return 1
            fi
            ;;
        function)
            if [[ -z $(echo "$content" | jq -r '.[]') ]]; then
                log "Error: No functions specified for function step" error
                return 1
            fi
            ;;
        *)
            log "Error: Unknown step type '$step_type'" error
            return 1
            ;;
    esac
    return 0
}

# Function to execute an apt or pipx step
execute_package_step() {
    local type="$1"
    local content="$2"
    local packages=$(echo "$content" | jq -r '.[]')
    "install_${type}_packages" $packages
}

# Function to execute a github step
execute_github_step() {
    local content="$1"
    echo "$content" | jq -c '.[]' | while read -r repo; do
        local ghUsername=$(echo "$repo" | jq -r '.ghUsername')
        local ghRepoName=$(echo "$repo" | jq -r '.ghRepoName')
        local binaries=$(echo "$repo" | jq -r '.binaries[]')
        install_from_github "$ghUsername/$ghRepoName" $binaries
    done
}

# Function to execute a command step
execute_command_step() {
    local content="$1"
    echo "$content" | jq -r '.[]' | while read -r cmd; do
        log "Executing command: $cmd" debug
        if ! output=$(eval "$cmd" 2>&1); then
            log "Command execution failed: $cmd" error
            log "Error output: $output" error
        else
            log "Command executed successfully: $cmd" info
            [[ -n "$output" ]] && log "Command output: $output" debug
        fi
    done
}

# Function to execute a function step
execute_function_step() {
    local content="$1"
    echo "$content" | jq -c '.[]' | while read -r func; do
        local name=$(echo "$func" | jq -r '.name')
        local args=$(echo "$func" | jq -r '.args[]')
        log "Calling function: $name $args" debug
        if ! $name $args; then
            log "Function call failed: $name" error
            return 1
        fi
    done
}

# Function to execute a single step
execute_step() {
    local step="$1"
    local step_type=$(echo "$step" | jq -r 'keys[0]')
    local message=$(echo "$step" | jq -r ".$step_type.message // \"Executing $step_type step\"")
    local comment=$(echo "$step" | jq -r ".$step_type.comment // \"\"")
    local content=$(echo "$step" | jq -r ".$step_type.content")

    log "$message" info
    [[ -n "$comment" ]] && log "Comment: $comment" debug

    case "$step_type" in
        apt|pipx)
            execute_package_step "$step_type" "$content"
            ;;
        github)
            execute_github_step "$content"
            ;;
        command)
            execute_command_step "$content"
            ;;
        function)
            execute_function_step "$content"
            ;;
        *)
            log "Unknown step type: $step_type" error
            return 1
            ;;
    esac

    log "Step completed: $message" info
}
