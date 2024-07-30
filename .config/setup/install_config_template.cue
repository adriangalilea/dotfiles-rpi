package config

// Define the structure for a GitHub package
#GitHubPackage: {
	repo:     string // Format: "username/repo"
	binaries: [...string] // List of binary names to install
	asset?:   string // Optional: Specific asset to download (e.g., "broot.zip")
}

// Define the structure for different types of steps
#AptStep: {
	name:     string
	type:     "apt"
	packages: [...string]
}

#PipxStep: {
	name:     string
	type:     "pipx"
	packages: [...string]
}

#GitHubStep: {
	name:     string
	type:     "github"
	packages: [...#GitHubPackage]
}

#CommandStep: {
	name:    string
	type:    "command"
	command: string
}

#FunctionStep: {
	name:     string
	type:     "function"
	function: string
	args?:    [...string]
}

// Union of all step types
#Step: #AptStep | #PipxStep | #GitHubStep | #CommandStep | #FunctionStep

// Define the overall configuration structure
#Config: {
	steps: [...#Step]
}

// Template for the configuration
template: #Config
