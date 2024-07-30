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
    
    local steps
    steps=$(yq e '.steps[] | .name' "$yaml_file") || {
        echo "Error: Failed to parse steps from YAML." >&2
        return 1
    }
    
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
        type|function|command)
            result=$(yq e ".steps[] | select(.name == \"$step_name\") | .$detail" "$yaml_file")
            ;;
        packages|args)
            result=$(yq e ".steps[] | select(.name == \"$step_name\") | .$detail[]" "$yaml_file")
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
    }
    
    local valid_types=("apt" "pipx" "github" "command" "function")
    local errors=()
    
    while IFS= read -r step; do
        local type=$(get_step_details "$step" "type" "$yaml_file")
        if [[ ! " ${valid_types[@]} " =~ " ${type} " ]]; then
            errors+=("Invalid type '$type' for step '$step'")
        fi
        
        case "$type" in
            apt|pipx|github)
                if ! get_step_details "$step" "packages" "$yaml_file" &> /dev/null; then
                    errors+=("Missing 'packages' for $type step '$step'")
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
    
    echo "Configuration validation passed."
}