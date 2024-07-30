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
			name: "Update APT"
			type: "function"
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
				"helix-editor/helix:helix",
				"eza-community/eza:eza",
				"jesseduffield/lazygit:lazygit",
				"dundee/gdu:gdu",
				"junegunn/fzf:fzf",
				"dandavison/delta:delta",
				"errata-ai/vale:vale",
				"errata-ai/vale-ls:vale-ls",
				"sxyazi/yazi:yazi",
				"achannarasappa/ticker:ticker",
				"humanlogio/humanlog:humanlog",
				"zaghaghi/openapi-tui:openapi-tui",
				"tbillington/kondo:kondo",
				"ynqa/jnv:jnv",
				"jwt-rs/jwt-ui:jwtui",
				"csvlens/releases:csvlens",
				"yassinebridi/serpl:serpl",
				"zellij-org/zellij:zellij",
				"Feel-ix-343/markdown-oxide:markdown-oxide",
				"adriangalilea/xdg-dirs:xdg-dirs",
			]
		},
		{
			name: "Install Clipboard"
			type: "command"
			command: "curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh"
		},
		{
			name: "Install Direnv"
			type: "command"
			command: "curl -sfL https://direnv.net/install.sh | bash"
		},
		{
			name: "Setup SSH Clipboard Forwarding"
			type: "function"
			function: "setup_ssh_clipboard_forwarding"
		},
		{
			name: "Increase Swap Size"
			type: "function"
			function: "increase_swap_size"
			args: ["1024"]
		},
		{
			name: "Setup Custom MOTD"
			type: "function"
			function: "setup_custom_motd"
		},
	]
}

// Validate the configuration
config: rpiConfig
