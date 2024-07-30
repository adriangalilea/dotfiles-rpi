package config

// Define the structure for a GitHub package
#GitHubPackage: {
	repo:     string // Format: "username/repo"
	binaries: [...string] // List of binary names to install
	asset?:   string // Optional: Specific asset to download (e.g., "broot.zip")
	comment?: string // Optional: Comment or documentation for the package
}

// Define the structure for different types of steps
#AptStep: {
	name:     string
	type:     "apt"
	packages: [...string]
	comment?: string
}

#PipxStep: {
	name:     string
	type:     "pipx"
	packages: [...string]
	comment?: string
}

#GitHubStep: {
	name:     string
	type:     "github"
	packages: [...#GitHubPackage]
	comment?: string
}

#CommandStep: {
	name:    string
	type:    "command"
	command: string
	comment?: string
}

#FunctionStep: {
	name:     string
	type:     "function"
	function: string
	args?:    [...string]
	comment?: string
}

// Union of all step types
#Step: #AptStep | #PipxStep | #GitHubStep | #CommandStep | #FunctionStep

// Define the overall configuration structure
#Config: {
	steps: [...#Step]
}

// Template for the configuration
template: #Config
