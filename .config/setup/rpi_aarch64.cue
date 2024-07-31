package rpi

// Extend the template for Raspberry Pi (Linux ARM64) configuration
import "dotfiles.install/template"

steps: [
	template.#Step & {
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
				{ghUsername: "helix-editor", ghReponame: "helix", binaries: ["hx"]},
				{ghUsername: "eza-community", ghReponame: "eza", binaries: ["eza"]},
				{ghUsername: "jesseduffield", ghReponame: "lazygit", binaries: ["lazygit"]},
				{ghUsername: "dundee", ghReponame: "gdu", binaries: ["gdu"]},
				{ghUsername: "junegunn", ghReponame: "fzf", binaries: ["fzf"]},
				{ghUsername: "dandavison", ghReponame: "delta", binaries: ["delta"]},
				{ghUsername: "errata-ai", ghReponame: "vale", binaries: ["vale"]},
				{ghUsername: "errata-ai", ghReponame: "vale-ls", binaries: ["vale-ls"]},
				{ghUsername: "sxyazi", ghReponame: "yazi", binaries: ["yazi", "ya"]},
				{ghUsername: "achannarasappa", ghReponame: "ticker", binaries: ["ticker"]},
				{ghUsername: "humanlogio", ghReponame: "humanlog", binaries: ["humanlog"]},
				{ghUsername: "zaghaghi", ghReponame: "openapi-tui", binaries: ["openapi-tui"]},
				{ghUsername: "tbillington", ghReponame: "kondo", binaries: ["kondo"]},
				{ghUsername: "ynqa", ghReponame: "jnv", binaries: ["jnv"]},
				{ghUsername: "jwt-rs", ghReponame: "jwtui", binaries: ["jwtui"]},
				{ghUsername: "csvlens", ghReponame: "csvlens", binaries: ["csvlens"]},
				{ghUsername: "yassinebridi", ghReponame: "serpl", binaries: ["serpl"]},
				{ghUsername: "zellij-org", ghReponame: "zellij", binaries: ["zellij"]},
				{ghUsername: "Feel-ix-343", ghReponame: "markdown-oxide", binaries: ["markdown-oxide"]},
				{ghUsername: "adriangalilea", ghReponame: "xdg-dirs", binaries: ["xdg-dirs"]},
				{ghUsername: "Canop", ghReponame: "broot", binaries: ["broot"]},
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

