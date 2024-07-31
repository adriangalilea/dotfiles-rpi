#!/bin/zsh

# Global variables
YAML_CONFIG_PATH="/tmp/install_config.yaml"

# Function to generate YAML from CUE
generate_yaml_from_cue() {
    local cue_file="$1"
    local yaml_file="${2:-$YAML_CONFIG_PATH}"
    
    if ! command -v cue &> /dev/null; then
        log "Error: 'cue' command not found. Please install CUE." error
        return 1
    fi
    
    log "Exporting CUE to YAML: $cue_file -> $yaml_file" debug
    if ! cue export "$cue_file" --out yaml > "$yaml_file"; then
        log "Error: Failed to generate YAML from CUE file." error
        log "CUE file contents:" debug
        cat "$cue_file" >&2
        return 1
    fi
    
    log "Successfully generated YAML from CUE" info
    log "Generated YAML contents:" debug
    cat "$yaml_file" >&2
}

# Function to parse the configuration
parse_config() {
    local cue_file="$1"
    local yaml_file="${2:-$YAML_CONFIG_PATH}"
    
    log "Generating YAML from CUE file: $cue_file" debug
    if ! generate_yaml_from_cue "$cue_file" "$yaml_file"; then
        log "Failed to generate YAML from CUE file" error
        return 1
    fi
    
    if ! command -v yq &> /dev/null; then
        log "Error: 'yq' command not found. Please install yq." error
        return 1
    fi
    
    log "Validating configuration" debug
    if ! validate_config "$yaml_file"; then
        log "Configuration validation failed" error
        return 1
    fi
    
    local steps
    log "Parsing steps from YAML" debug
    if ! steps=$(yq '.config.steps[].name' "$yaml_file"); then
        log "Failed to parse steps from YAML" error
        return 1
    fi
    
    if [[ -z "$steps" ]]; then
        log "No steps found in the configuration" error
        return 1
    fi
    
    log "Steps found: $steps" debug
    
    log "Successfully parsed configuration" info
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
        type|function|command|comment|args|packages)
            result=$(yq ".config.steps[] | select(.name == \"$step_name\") | .$detail" "$yaml_file")
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
            local packages=($(get_step_details "$step" "packages"))
            if [[ ${#packages[@]} -eq 0 ]]; then
                log "Error: No packages specified for apt step '$step_name'" error
                return 1
            fi
            install_apt_packages "${packages[@]}"
            ;;
        pipx)
            local packages=($(get_step_details "$step" "packages"))
            if [[ ${#packages[@]} -eq 0 ]]; then
                log "Error: No packages specified for pipx step '$step_name'" error
                return 1
            fi
            install_pipx_packages "${packages[@]}"
            ;;
        github)
            local packages=$(get_step_details "$step" "packages")
            if [[ -z "$packages" ]]; then
                log "Error: No packages specified for github step '$step_name'" error
                return 1
            fi
            local github_args=()
            while IFS= read -r package; do
                local repo=$(echo "$package" | yq e '.repo' -)
                local binaries=($(echo "$package" | yq e '.binaries[]' -))
                if [[ -n "$repo" && ${#binaries[@]} -gt 0 ]]; then
                    for binary in "${binaries[@]}"; do
                        github_args+=("$repo" "$binary")
                    done
                else
                    log "Warning: Invalid package format for '$repo'. Skipping." warn
                fi
            done < <(yq e '.packages[]' <<< "$packages")
            log "Calling install_from_github with args: ${github_args[@]}" debug
            if [[ ${#github_args[@]} -eq 0 ]]; then
                log "Error: No valid GitHub packages found for step '$step_name'" error
                return 1
            fi
            install_from_github "${github_args[@]}"
            ;;
        command)
            local command=$(get_step_details "$step" "command")
            if [[ -z "$command" ]]; then
                log "Error: No command specified for command step '$step_name'" error
                return 1
            fi
            log "Executing command: $command" debug
            local output
            if ! output=$(eval "$command" 2>&1); then
                log "Command execution failed: $command" error
                log "Error output: $output" error
                return 1
            else
                log "Command executed successfully: $command" info
                if [[ -n "$output" ]]; then
                    log "Command output: $output" debug
                fi
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
    
    yq '.steps[].name' "$yaml_file"
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
        local type=$(yq ".config.steps[] | select(.name == \"$step\") | .type" "$yaml_file")
        if [[ ! " ${valid_types[@]} " =~ " ${type} " ]]; then
            errors+=("Invalid type '$type' for step '$step'")
        fi
        
        case "$type" in
            apt|pipx)
                if [[ -z $(yq ".config.steps[] | select(.name == \"$step\") | .packages" "$yaml_file") ]]; then
                    errors+=("Missing 'packages' for $type step '$step'")
                fi
                ;;
            github)
                local packages=$(yq ".config.steps[] | select(.name == \"$step\") | .packages" "$yaml_file")
                if [[ -z "$packages" ]]; then
                    errors+=("Missing 'packages' for github step '$step'")
                else
                    while IFS= read -r package; do
                        if [[ -z $(echo "$package" | yq ".repo") ]]; then
                            errors+=("Missing 'repo' for a package in github step '$step'")
                        fi
                        if [[ -z $(echo "$package" | yq ".binaries[]") ]]; then
                            errors+=("Missing 'binaries' for a package in github step '$step'")
                        fi
                        local repo=$(echo "$package" | yq ".repo")
                        log "Validating package: $repo in github step '$step'" debug
                    done < <(echo "$packages" | yq -o=json -I=0 '.')
                fi
                ;;
            command)
                if [[ -z $(yq ".steps[] | select(.name == \"$step\") | .command" "$yaml_file") ]]; then
                    errors+=("Missing 'command' for command step '$step'")
                fi
                ;;
            function)
                if [[ -z $(yq ".steps[] | select(.name == \"$step\") | .function" "$yaml_file") ]]; then
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
