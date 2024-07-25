# Collection of hand-crafted cli utils

> [!NOTE]  
> Note some tools may not be documented and subject to change

## Smaller functions are available on [~/.config/shell/functions](../functions)

## [`sys`](https://github.com/adriangalilea/dotfiles-rpi/blob/92afee4de28aa5e26dffc438d71364bd00f50998/.config/shell/.functions#L62)
<img width="260" alt="image" src="https://github.com/user-attachments/assets/59c06811-b290-4351-a6e4-c3e91c4ec1b4">

## [`dif`](https://github.com/adriangalilea/dotfiles-rpi/blob/92afee4de28aa5e26dffc438d71364bd00f50998/.config/shell/.functions#L154)

<img width="765" alt="image" src="https://github.com/user-attachments/assets/af434b5f-908d-4945-bec0-8459d3b1a54f">


```
» dif -h                                                                                                            
Usage: dif <file1> <file2>
Compare two files or URLs, including GitHub repositories.

Supported formats:
  - Local files
  - GitHub shorthand: git:{repo}:{[optional, default=main/master]branch}:{filepath}
    ex: git:adriangalilea/dotfiles-rpi:.config/shell/.aliases
  - GitHub regular URLs: https://github.com/adriangalilea/dotfiles-rpi/blob/master/.config/shell/.aliases
  - GitHub raw URLs: https://raw.githubusercontent.com/adriangalilea/dotfiles-rpi/master/.config/shell/.aliases

Examples:
  1. Compare local file to GitHub shorthand:
     dif ~/.config/shell/.aliases git:adriangalilea/dotfiles-rpi:.config/shell/.aliases

  2. Compare two GitHub repositories using shorthand:
     dif git:adriangalilea/dotfiles-rpi:.config/shell/.aliases git:sobolevn/dotfiles:shell/.aliases

  3. Compare GitHub shorthand to GitHub regular URL:
     dif git:adriangalilea/dotfiles-rpi:.config/shell/.completions https://github.com/sobolevn/dotfiles/blob/master/shell/.completions

  4. Compare local file to GitHub raw URL:
     dif ~/.config/shell/.completions https://raw.githubusercontent.com/sobolevn/dotfiles/master/shell/.completions

  5. Compare GitHub regular URL to GitHub raw URL:
     dif https://github.com/adriangalilea/dotfiles-rpi/blob/master/.config/shell/.aliases https://raw.githubusercontent.com/sobolevn/dotfiles/master/shell/.aliases

  6. Compare two local files:
     dif ~/.config/shell/.aliases ~/.config/shell/.completions

  7. Compare GitHub shorthand with specific branch to GitHub regular URL:
     dif git:adriangalilea/dotfiles-rpi:main:.config/shell/.aliases https://github.com/sobolevn/dotfiles/blob/master/shell/.aliases
```
