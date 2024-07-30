package config

import (
	"list"
)

// Import the template
import "install_config_template.cue"

// Extend the template for Raspberry Pi (Linux ARM64) configuration
rpiConfig: template & {
	steps: [
		{
			name:     "Update APT"
			type:     "function"
			function: "update_package_lists"
		},
		{
			name: "Install APT Packages"
			type: "apt"
			packages: [
				"zsh", "git", "wget", "curl", "jq", "tar", "xz-utils", "htop", "neofetch", "bat",
				"build-essential", "dh-make", "devscripts", "golang", "python3-pip", "fd-find", "tree", "tmux", "shellcheck",
				"glow", "freeze",
			]
		},
		{
			name: "Install PIPX Packages"
			type: "pipx"
			packages: ["dtj", "tldr", "yt-dlp", "periodic-table-cli"]
		},
		{
			name: "Install GitHub Packages"
			type: "github"
			packages: [
				{repo: "helix-editor/helix", binaries: ["hx"]},
				{repo: "eza-community/eza", binaries: ["eza"]},
				{repo: "jesseduffield/lazygit", binaries: ["lazygit"]},
				{repo: "dundee/gdu", binaries: ["gdu"]},
				{repo: "junegunn/fzf", binaries: ["fzf"]},
				{repo: "dandavison/delta", binaries: ["delta"]},
				{repo: "errata-ai/vale", binaries: ["vale"]},
				{repo: "errata-ai/vale-ls", binaries: ["vale-ls"]},
				{repo: "sxyazi/yazi", binaries: ["yazi", "yazi-plugin"]},
				{repo: "achannarasappa/ticker", binaries: ["ticker"]},
				{repo: "humanlogio/humanlog", binaries: ["humanlog"]},
				{repo: "zaghaghi/openapi-tui", binaries: ["openapi-tui"]},
				{repo: "tbillington/kondo", binaries: ["kondo"]},
				{repo: "ynqa/jnv", binaries: ["jnv"]},
				{repo: "jwt-rs/jwt-ui", binaries: ["jwtui"]},
				{repo: "csvlens/releases", binaries: ["csvlens"]},
				{repo: "yassinebridi/serpl", binaries: ["serpl"]},
				{repo: "zellij-org/zellij", binaries: ["zellij"]},
				{repo: "Feel-ix-343/markdown-oxide", binaries: ["markdown-oxide"]},
				{repo: "adriangalilea/xdg-dirs", binaries: ["xdg-dirs"]},
				{repo: "Canop/broot", binaries: ["broot"], asset: "broot.zip"},
			]
		},
		{
			name:    "Install Clipboard"
			type:    "command"
			command: "curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh"
		},
		{
			name:    "Install Direnv"
			type:    "command"
			command: "curl -sfL https://direnv.net/install.sh | bash"
		},
		{
			name:     "Setup SSH Clipboard Forwarding"
			type:     "function"
			function: "setup_ssh_clipboard_forwarding"
		},
		{
			name:     "Increase Swap Size"
			type:     "function"
			function: "increase_swap_size"
			args:     ["1024"]
		},
		{
			name:     "Setup Custom MOTD"
			type:     "function"
			function: "setup_custom_motd"
		},
	]
}

// Validate the configuration
config: rpiConfig
