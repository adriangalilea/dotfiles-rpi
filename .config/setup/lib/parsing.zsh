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
    local cue_file="$1"
    local json_file="${2:-$JSON_CONFIG_PATH}"

    log "Generating JSON from CUE file: $cue_file" debug
    if ! generate_json_from_cue "$cue_file" "$json_file"; then
        log "Failed to generate JSON from CUE file" error
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        log "Error: 'jq' command not found. Please install jq." error
        return 1
    fi

    log "Validating configuration" debug
    if ! validate_config "$json_file"; then
        log "Configuration validation failed" error
        return 1
    fi

    local steps
    log "Parsing steps from JSON" debug
    if ! steps=$(jq -r '.steps[] | "\(.name)|\(.type)"' "$json_file"); then
        log "Failed to parse steps from JSON" error
        return 1
    fi

    if [[ -z "$steps" ]]; then
        log "No steps found in the configuration" error
        return 1
    fi

    log "Successfully parsed configuration" info
    echo "$steps"
}
                                                                                                      
 # Function to get step details                                                                       
 get_step_details() {                                                                                 
     local step_name="$1"                                                                             
     local detail="$2"                                                                                
     local json_file="${3:-$JSON_CONFIG_PATH}"                                                        
                                                                                                      
     if [[ ! -f "$json_file" ]]; then                                                                 
         log "Error: JSON file not found. Run parse_config first." error                              
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     local result                                                                                     
     case "$detail" in                                                                                
         name)                                                                                        
             result="$step_name"                                                                      
             ;;                                                                                       
         type|function|command|comment|args|packages|repo|binaries|asset)
             result=$(jq -r --arg name "$step_name" --arg detail "$detail" '.steps[] | select(.name == $name) | .[$detail]' "$json_file")
             ;;                                                                                       
         *)                                                                                           
             log "Error: Unknown detail type '$detail'." error                                        
             return 1                                                                                 
             ;;                                                                                       
     esac                                                                                             
                                                                                                      
     if [[ -z "$result" || "$result" == "null" ]]; then                                               
         log "Error: Failed to retrieve '$detail' for step '$step_name'." error                       
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     echo "$result"                                                                                   
 }                                                                                                    
                                                                                                      
 # Function to execute a step                                                                         
 execute_step() {                                                                                     
     local step="$1"                                                                                  
     local step_type                                                                                  
                                                                                                      
     if [[ -z "$step" ]]; then                                                                        
         log "Error: Empty step name provided to execute_step" error                                  
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     step_type=$(get_step_details "$step" "type")                                                     
     if [[ -z "$step_type" ]]; then                                                                   
         log "Error: Failed to get type for step '$step'" error                                       
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     log "Executing step: $step (Type: $step_type)" info                                              
                                                                                                      
     case "$step_type" in                                                                             
         apt|pipx)                                                                                    
             local packages=$(get_step_details "$step" "packages")
             if [[ -z "$packages" ]]; then
                 log "Error: No packages specified for $step_type step '$step'" error
                 return 1
             fi
             local package_names=($(echo "$packages" | jq -r '.[].name'))
             "install_${step_type}_packages" "${package_names[@]}"
             ;;
         github)
             local packages=$(get_step_details "$step" "packages")
             if [[ -z "$packages" ]]; then
                 log "Error: No packages specified for github step '$step'" error
                 return 1
             fi
             local github_args=()
             while IFS= read -r package; do
                 local repo=$(echo "$package" | jq -r '.repo')
                 local binaries=($(echo "$package" | jq -r '.binaries[]'))
                 local asset=$(echo "$package" | jq -r '.asset')
                 if [[ -n "$repo" && ${#binaries[@]} -gt 0 ]]; then
                     for binary in "${binaries[@]}"; do
                         github_args+=("$repo" "$binary" "$asset")
                     done
                 else
                     log "Warning: Invalid package format for '$repo'. Skipping." warn
                 fi
             done < <(echo "$packages" | jq -c '.[]')
             if [[ ${#github_args[@]} -eq 0 ]]; then
                 log "Error: No valid GitHub packages found for step '$step'" error
                 return 1
             fi
             install_from_github "${github_args[@]}"
             ;;
         command)
             local command=$(get_step_details "$step" "command")
             if [[ -z "$command" ]]; then
                 log "Error: No command specified for command step '$step'" error
                 return 1
             fi
             log "Executing command: $command" debug
             if ! output=$(eval "$command" 2>&1); then
                 log "Command execution failed: $command" error
                 log "Error output: $output" error
                 return 1
             fi
             log "Command executed successfully: $command" info
             [[ -n "$output" ]] && log "Command output: $output" debug
             ;;
         function)
             local function=$(get_step_details "$step" "function")
             if [[ -z "$function" ]]; then
                 log "Error: No function specified for function step '$step'" error
                 return 1
             fi
             local args=$(get_step_details "$step" "args" 2>/dev/null)
             log "Calling function: $function" debug
             if ! $function $args; then
                 log "Function call failed: $function" error
                 return 1
             fi
             ;;
         *)
             log "Unknown step type: $step_type" error
             return 1
             ;;
     esac

     log "Step completed: $step" info
}
                                                                                                      
 # Function to validate the configuration                                                             
 validate_config() {                                                                                  
     local json_file="${1:-$JSON_CONFIG_PATH}"                                                        
                                                                                                      
     if [[ ! -f "$json_file" ]]; then                                                                 
         log "Error: JSON file not found. Run parse_config first." error                              
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     local valid_types=("apt" "pipx" "github" "command" "function")                                   
     local errors=()                                                                                  
                                                                                                      
     while IFS= read -r step; do                                                                      
         local name=$(echo "$step" | jq -r '.name')                                                   
         local type=$(echo "$step" | jq -r '.type')                                                   
                                                                                                      
         if [[ ! " ${valid_types[@]} " =~ " ${type} " ]]; then                                        
             errors+=("Invalid type '$type' for step '$name'")                                        
         fi                                                                                           
                                                                                                      
         case "$type" in                                                                              
             apt|pipx|github)                                                                         
                 if [[ -z $(echo "$step" | jq -r '.packages') ]]; then                                
                     errors+=("Missing 'packages' for $type step '$name'")                            
                 elif [[ "$type" == "github" ]]; then                                                 
                     while IFS= read -r package; do                                                   
                         if [[ -z $(echo "$package" | jq -r '.repo') ]]; then                         
                             errors+=("Missing 'repo' for a package in github step '$name'")          
                         fi                                                                           
                         if [[ -z $(echo "$package" | jq -r '.binaries[]') ]]; then                   
                             errors+=("Missing 'binaries' for a package in github step '$name'")      
                         fi                                                                           
                     done < <(echo "$step" | jq -c '.packages[]')                                     
                 fi                                                                                   
                 ;;                                                                                   
             command)                                                                                 
                 if [[ -z $(echo "$step" | jq -r '.command') ]]; then                                 
                     errors+=("Missing 'command' for command step '$name'")                           
                 fi                                                                                   
                 ;;                                                                                   
             function)                                                                                
                 if [[ -z $(echo "$step" | jq -r '.function') ]]; then                                
                     errors+=("Missing 'function' for function step '$name'")                         
                 fi                                                                                   
                 ;;                                                                                   
         esac                                                                                         
     done < <(jq -c '.config.steps[]' "$json_file")                                                   
                                                                                                      
     if ((${#errors[@]} > 0)); then                                                                   
         log "Configuration validation failed:" error                                                 
         printf '%s\n' "${errors[@]}" >&2                                                             
         return 1                                                                                     
     fi                                                                                               
                                                                                                      
     return 0                                                                                         
 }   
