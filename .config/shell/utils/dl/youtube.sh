#!/bin/bash

# Function to download from YouTube
download_from_youtube() {
    local url=$1 dest_path=$2 interactive=$3 force=$4

    if ! command -v yt-dlp &> /dev/null; then
        logs error "yt-dlp is not installed. It's required for YouTube downloads."
        if command -v gum &> /dev/null; then
            gum confirm "Do you want to continue without yt-dlp? (GitHub downloads will still work)" || exit 1
        else
            read -r -p "Do you want to continue without yt-dlp? (GitHub downloads will still work) [y/N] " REPLY
            [[ $REPLY =~ ^[Yy]$ ]] || exit 1
        fi
        return
    fi

    local format
    if [[ $interactive = "-i" ]]; then
        format=$(select_youtube_format)
    else
        format="🎥 Video (best quality)"
    fi

    download_youtube_content "$url" "$dest_path" "$format" "$force"
}

# Function to select YouTube download format
select_youtube_format() {
    if command -v gum &> /dev/null; then
        gum choose "🎥 Video (best quality)" "🔊 Audio only (best quality)" --header "⬇️ Select format"
    else
        logs info "Select download format:"
        select format in "🎥 Video (best quality)" "🔊 Audio only (best quality)"; do
            echo "$format"
            break
        done
    fi
}

# Function to download YouTube content
download_youtube_content() {
    local url=$1 dest_path=$2 format=$3 force=$4
    mkdir -p "$dest_path"
    cd "$dest_path" || return 1

    local yt_dlp_options=""
    [[ $force = "--force" ]] && yt_dlp_options+=" --no-continue"

    if [[ $format = "🔊 Audio only (best quality)" ]]; then
        gum spin --spinner dot --title "🔊 Downloading audio..." -- yt-dlp -x --audio-format mp3 --audio-quality 0 $yt_dlp_options "$url"
        logs info "✅ Downloaded audio from YouTube"
    else
        gum spin --spinner dot --title "🎥 Downloading video..." -- yt-dlp -f bestvideo+bestaudio $yt_dlp_options "$url"
        logs info "✅ Downloaded video from YouTube"
    fi
}
