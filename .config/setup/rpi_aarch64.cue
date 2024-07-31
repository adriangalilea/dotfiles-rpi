package rpi

import "dotfiles.install/template"

// Extend the template for Raspberry Pi (Linux ARM64) configuration
rpiConfig: template & {
	steps: [
		{
			name: "Install APT Packages"
			type: "apt"
			packages: [
				{name: "zsh"}, {name: "git"}, {name: "wget"}, {name: "curl"}, {name: "jq"}, {name: "tar"}, {name: "xz-utils"}, {name: "htop"}, {name: "neofetch"}, {name: "bat"},
				{name: "build-essential"}, {name: "dh-make"}, {name: "devscripts"}, {name: "golang"}, {name: "python3-pip"}, {name: "fd-find"}, {name: "tree"}, {name: "tmux"}, {name: "shellcheck"},
				{name: "glow"}, {name: "freeze"},
			]
		},
		{
			name: "Install PIPX Packages"
			type: "pipx"
			packages: [{name: "dtj"}, {name: "tldr"}, {name: "yt-dlp"}, {name: "periodic-table-cli"}]
		},
		{
			name: "Install GitHub Packages"
			type: "github"
			packages: [
				{name: "helix", repo: "helix-editor/helix", binaries: ["hx"]},
				{name: "eza", repo: "eza-community/eza", binaries: ["eza"]},
				{name: "lazygit", repo: "jesseduffield/lazygit", binaries: ["lazygit"]},
				{name: "gdu", repo: "dundee/gdu", binaries: ["gdu"]},
				{name: "fzf", repo: "junegunn/fzf", binaries: ["fzf"]},
				{name: "delta", repo: "dandavison/delta", binaries: ["delta"]},
				{name: "vale", repo: "errata-ai/vale", binaries: ["vale"]},
				{name: "vale-ls", repo: "errata-ai/vale-ls", binaries: ["vale-ls"]},
				{name: "yazi", repo: "sxyazi/yazi", binaries: ["yazi", "ya"]},
				{name: "ticker", repo: "achannarasappa/ticker", binaries: ["ticker"]},
				{name: "humanlog", repo: "humanlogio/humanlog", binaries: ["humanlog"]},
				{name: "openapi-tui", repo: "zaghaghi/openapi-tui", binaries: ["openapi-tui"]},
				{name: "kondo", repo: "tbillington/kondo", binaries: ["kondo"]},
				{name: "jnv", repo: "ynqa/jnv", binaries: ["jnv"]},
				{name: "jwtui", repo: "jwt-rs/jwt-ui", binaries: ["jwtui"]},
				{name: "csvlens", repo: "csvlens/releases", binaries: ["csvlens"]},
				{name: "serpl", repo: "yassinebridi/serpl", binaries: ["serpl"]},
				{name: "zellij", repo: "zellij-org/zellij", binaries: ["zellij"]},
				{name: "markdown-oxide", repo: "Feel-ix-343/markdown-oxide", binaries: ["markdown-oxide"]},
				{name: "xdg-dirs", repo: "adriangalilea/xdg-dirs", binaries: ["xdg-dirs"]},
				{
					name: "broot"
					repo: "Canop/broot"
					binaries: ["broot"]
					asset:   "broot.zip"
					comment: "Download the latest zip, unzip, contains all the binaries for each distribution, pick the right one, move to /usr/local/bin/."
				},
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
			args: ["1024"]
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
