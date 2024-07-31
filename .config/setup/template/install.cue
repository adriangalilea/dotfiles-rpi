package template

// Define the structure for a package (used for apt, pipx, and github)
#Package: {
	name:     string
	repo?:    string  // For GitHub packages
	binaries?: [...string] // For GitHub packages
	asset?:   string  // For GitHub packages
	comment?: string
}

// Define the structure for different types of steps
#Step: {
	name:     string
	type:     "apt" | "pipx" | "github" | "command" | "function"
	packages?: [...#Package]
	command?:  string
	function?: string
	args?:     [...string]
	comment?:  string
}

// Define the overall configuration structure
#Config: {
	steps: [...#Step]
}

// Template for the configuration
template: #Config
