package template

#Step: {
	apt?: {
		message?: string
		comment?: string
		content: [...string]
	}
	pipx?: {
		message?: string
		comment?: string
		content: [...string]
	}
	github?: {
		message?: string
		comment?: string
		content: [...{
			ghUsername: string
			ghReponame: string
			binaries: [...string]
		}]
	}
	command?: {
		message?: string
		comment?: string
		content: [...string]
	}
	function?: {
		message?: string
		comment?: string
		content: [...{
			name: string
			args: [...string]
		}]
	}
}

steps: [...#Step]

template: steps
