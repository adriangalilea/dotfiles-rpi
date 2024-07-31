package rpi

import "dotfiles.install/template"

// Extend the template for Raspberry Pi (Linux ARM64) configuration
steps: [...template.#Step] & [
	{
		apt: {
			message: "Install essential system packages"
			comment: "These packages are required for basic system functionality and development"
			content: [
				"zsh", "git", "wget", "curl", "jq", "tar", "xz-utils", "htop", "neofetch", "bat",
				"build-essential", "dh-make", "devscripts", "golang", "python3-pip", "fd-find", "tree", "tmux", "shellcheck",
				"glow", "freeze",
			]
		}
	},
	{
		pipx: {
			message: "Install Python packages globally"
			comment: "These Python tools are installed globally using pipx"
			content: ["dtj", "tldr", "yt-dlp", "periodic-table-cli"]
		}
	},
	{
		github: {
			message: "Install tools from GitHub repositories"
			comment: "These tools are downloaded and installed directly from GitHub"
			content: [
				{ghUsername: "helix-editor", ghRepoName: "helix", binaries: ["hx"]},
				{ghUsername: "eza-community", ghRepoName: "eza", binaries: ["eza"]},
				{ghUsername: "jesseduffield", ghRepoName: "lazygit", binaries: ["lazygit"]},
				{ghUsername: "dundee", ghRepoName: "gdu", binaries: ["gdu"]},
				{ghUsername: "junegunn", ghRepoName: "fzf", binaries: ["fzf"]},
				{ghUsername: "dandavison", ghRepoName: "delta", binaries: ["delta"]},
				{ghUsername: "errata-ai", ghRepoName: "vale", binaries: ["vale"]},
				{ghUsername: "errata-ai", ghRepoName: "vale-ls", binaries: ["vale-ls"]},
				{ghUsername: "sxyazi", ghRepoName: "yazi", binaries: ["yazi", "ya"]},
				{ghUsername: "achannarasappa", ghRepoName: "ticker", binaries: ["ticker"]},
				{ghUsername: "humanlogio", ghRepoName: "humanlog", binaries: ["humanlog"]},
				{ghUsername: "zaghaghi", ghRepoName: "openapi-tui", binaries: ["openapi-tui"]},
				{ghUsername: "tbillington", ghRepoName: "kondo", binaries: ["kondo"]},
				{ghUsername: "ynqa", ghRepoName: "jnv", binaries: ["jnv"]},
				{ghUsername: "jwt-rs", ghRepoName: "jwtui", binaries: ["jwtui"]},
				{ghUsername: "csvlens", ghRepoName: "csvlens", binaries: ["csvlens"]},
				{ghUsername: "yassinebridi", ghRepoName: "serpl", binaries: ["serpl"]},
				{ghUsername: "zellij-org", ghRepoName: "zellij", binaries: ["zellij"]},
				{ghUsername: "Feel-ix-343", ghRepoName: "markdown-oxide", binaries: ["markdown-oxide"]},
				{ghUsername: "adriangalilea", ghRepoName: "xdg-dirs", binaries: ["xdg-dirs"]},
				{ghUsername: "Canop", ghRepoName: "broot", binaries: ["broot"]},
			]
		}
	},
	{
		command: {
			message: "Install additional tools"
			comment: "Install Clipboard and Direnv using their installation scripts"
			content: [
				"curl -sSL https://github.com/Slackadays/Clipboard/raw/main/install.sh | sh",
				"curl -sfL https://direnv.net/install.sh | bash",
			]
		}
	},
	{
		function: {
			message: "Configure system settings"
			comment: "Set up various system configurations"
			content: [
				{name: "setup_ssh_clipboard_forwarding", args: []},
				{name: "increase_swap_size", args: ["1024"]},
				{name: "setup_custom_motd", args: []},
			]
		}
	},
]
