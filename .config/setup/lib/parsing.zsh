#!/bin/zsh

# Global variables
YAML_CONFIG_PATH="/tmp/install_config.yaml"

# Function to generate YAML from CUE
generate_yaml_from_cue() {
    local cue_file="$1"
    local yaml_file="${2:-$YAML_CONFIG_PATH}"
    
    if ! command -v cue &> /dev/null; then
        echo "Error: 'cue' command not found. Please install CUE." >&2
        return 1
    fi
    
    if ! cue export "$cue_file" --out yaml > "$yaml_file"; then
        echo "Error: Failed to generate YAML from CUE file." >&2
        return 1
    fi
}

# Function to parse the configuration
parse_config() {
    local cue_file="$1"
    local yaml_file="${2:-$YAML_CONFIG_PATH}"
    
    generate_yaml_from_cue "$cue_file" "$yaml_file" || return 1
    
    if ! command -v yq &> /dev/null; then
        echo "Error: 'yq' command not found. Please install yq." >&2
        return 1
    fi
    
    # Validate the configuration
    if ! validate_config "$yaml_file"; then
        return 1
    fi
    
    local steps
    steps=$(yq e '.config.steps[].name' "$yaml_file") || {
        echo "Error: Failed to parse steps from YAML." >&2
        return 1
    }
    
    if [[ -z "$steps" ]]; then
        echo "Error: No steps found in the configuration." >&2
        return 1
    fi
    
    echo "$steps"
}

# Function to get step details
get_step_details() {
    local step_name="$1"
    local detail="$2"
    local yaml_file="${3:-$YAML_CONFIG_PATH}"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo "Error: YAML file not found. Run parse_config first." >&2
        return 1
    fi
    
    local result
    case "$detail" in
        name)
            result="$step_name"
            ;;
        type|function|command|comment)
            result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .$detail" "$yaml_file")
            ;;
        packages)
            local step_type=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .type" "$yaml_file")
            case "$step_type" in
                github)
                    result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .$detail" "$yaml_file")
                    ;;
                apt|pipx)
                    result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .$detail[]" "$yaml_file")
                    ;;
                *)
                    echo "Error: Unknown step type '$step_type' for packages detail." >&2
                    return 1
                    ;;
            esac
            ;;
        repo)
            result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .packages[].repo" "$yaml_file")
            ;;
        binaries)
            result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .packages[].binaries[]" "$yaml_file")
            ;;
        args)
            result=$(yq e ".config.steps[] | select(.name == \"$step_name\") | .$detail[]" "$yaml_file")
            ;;
        *)
            echo "Error: Unknown detail type '$detail'." >&2
            return 1
            ;;
    esac
    
    if [[ -z "$result" ]]; then
        echo "Error: Failed to retrieve '$detail' for step '$step_name'." >&2
        return 1
    fi
    
    echo "$result"
}

# Function to execute a step
execute_step() {
    local step="$1"
    
    if [[ -z "$step" ]]; then
        log "Error: Empty step name provided to execute_step" error
        return 1
    fi
    
    local step_type=$(get_step_details "$step" "type")
    local step_name=$(get_step_details "$step" "name")
    
    if [[ -z "$step_type" ]]; then
        log "Error: Failed to retrieve 'type' for step '$step'" error
        return 1
    fi
    
    if [[ -z "$step_name" ]]; then
        log "Error: Failed to retrieve 'name' for step '$step'" error
        return 1
    fi
    
    log "Executing step: $step_name (Type: $step_type)" info
    
    case "$step_type" in
        apt)
            local packages=$(get_step_details "$step" "packages")
            if [[ -z "$packages" ]]; then
                log "Error: No packages specified for apt step '$step_name'" error
                return 1
            fi
            install_apt_packages $packages
            ;;
        pipx)
            local packages=$(get_step_details "$step" "packages")
            if [[ -z "$packages" ]]; then
                log "Error: No packages specified for pipx step '$step_name'" error
                return 1
            fi
            install_pipx_packages $packages
            ;;
        github)
            local repos=($(get_step_details "$step" "repo"))
            local binaries=($(get_step_details "$step" "binaries"))
            if [[ ${#repos[@]} -eq 0 || ${#binaries[@]} -eq 0 ]]; then
                log "Error: No packages specified for github step '$step_name'" error
                return 1
            fi
            local github_args=()
            for ((i=0; i<${#repos[@]}; i++)); do
                github_args+=("${repos[i]}" "${binaries[i]}")
            done
            install_from_github "${github_args[@]}"
            ;;
        command)
            local command=$(get_step_details "$step" "command")
            if [[ -z "$command" ]]; then
                log "Error: No command specified for command step '$step_name'" error
                return 1
            fi
            log "Executing command: $command" debug
            if ! eval "$command"; then
                log "Command execution failed: $command" error
                return 1
            fi
            ;;
        function)
            local function=$(get_step_details "$step" "function")
            if [[ -z "$function" ]]; then
                log "Error: No function specified for function step '$step_name'" error
                return 1
            fi
            local args=$(get_step_details "$step" "args" 2>/dev/null)
            log "Calling function: $function" debug
            if [[ -n "$args" ]]; then
                if ! $function $args; then
                    log "Function call failed: $function" error
                    return 1
                fi
            else
                if ! $function; then
                    log "Function call failed: $function" error
                    return 1
                fi
            fi
            ;;
        *)
            log "Unknown step type: $step_type" error
            return 1
            ;;
    esac
    
    log "Step completed: $step_name" info
    echo
}

# Function to get all step names
get_step_names() {
    local yaml_file="${1:-$YAML_CONFIG_PATH}"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo "Error: YAML file not found. Run parse_config first." >&2
        return 1
    fi
    
    yq e '.steps[].name' "$yaml_file"
}

# Function to validate the configuration
validate_config() {
    local yaml_file="${1:-$YAML_CONFIG_PATH}"
    
    if [[ ! -f "$yaml_file" ]]; then
        echo "Error: YAML file not found. Run parse_config first." >&2
        return 1
    fi
    
    local valid_types=("apt" "pipx" "github" "command" "function")
    local errors=()
    
    while IFS= read -r step; do
        local type=$(get_step_details "$step" "type" "$yaml_file")
        if [[ ! " ${valid_types[@]} " =~ " ${type} " ]]; then
            errors+=("Invalid type '$type' for step '$step'")
        fi
        
        case "$type" in
            apt|pipx)
                if ! get_step_details "$step" "packages" "$yaml_file" &> /dev/null; then
                    errors+=("Missing 'packages' for $type step '$step'")
                fi
                ;;
            github)
                local packages=$(get_step_details "$step" "packages" "$yaml_file")
                if [[ -z "$packages" ]]; then
                    errors+=("Missing 'packages' for github step '$step'")
                else
                    echo "$packages" | while IFS= read -r package; do
                        if ! echo "$package" | yq e ".repo" - &> /dev/null; then
                            errors+=("Missing 'repo' for a package in github step '$step'")
                        fi
                        if ! echo "$package" | yq e ".binaries[]" - &> /dev/null; then
                            errors+=("Missing 'binaries' for a package in github step '$step'")
                        fi
                        local repo=$(echo "$package" | yq e ".repo" -)
                        errors+=("Validating package: $repo in github step '$step'")
                    done
                fi
                ;;
            command)
                if ! get_step_details "$step" "command" "$yaml_file" &> /dev/null; then
                    errors+=("Missing 'command' for command step '$step'")
                fi
                ;;
            function)
                if ! get_step_details "$step" "function" "$yaml_file" &> /dev/null; then
                    errors+=("Missing 'function' for function step '$step'")
                fi
                ;;
        esac
    done < <(get_step_names "$yaml_file")
    
    if ((${#errors[@]} > 0)); then
        echo "Configuration validation failed:" >&2
        printf '%s\n' "${errors[@]}" >&2
        return 1
    fi
    
    return 0
}
