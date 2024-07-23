#!/bin/zsh

# Function to update the static line
update_static_line() {
    local message=$1
    echo -e "\033[1A\033[K$message"
}

run_with_spinner() {
    local title=$1
    shift
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
        source_files /home/adrian/.setup/installers
        $*
    "
}
