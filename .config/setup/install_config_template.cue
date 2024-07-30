package config

// Define the structure for a single step
#Step: {
	name:     string
	type:     "apt" | "pipx" | "github" | "command" | "function"
	packages?: [...string]
	command?:  string
	function?: string
	args?:     [...string]
}

// Define the overall configuration structure
#Config: {
	steps: [...#Step]
}

// Template for the configuration
template: #Config
