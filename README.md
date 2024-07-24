# RPi dotfiles

[This git repo is meant to be used as home `~`.](https://drewdevault.com/2019/12/30/dotfiles.html)

This repo is an attempt to have sane defaults for the various rpi's I have, the idea is to run the main.py as a boot script and have the very same environment in every rpi I flash.

Heavily inspired by [@sobolevn](https://github.com/sobolevn) [dotfiles](https://github.com/sobolevn/dotfiles) with many modifications, also merged my own dotfiles, tailored for the RPi's.

Assumes aarch64.

# Batteries included

## [Automated install of packages](./.setup/README.md)

## [HELIX](./.config/helix/README.md)

List of included apt packages: [pending]
List of included github binaries that install automatically: [pending]

## [aliases & shortcuts](https://github.com/adriangalilea/dotfiles-rpi/blob/master/.shell/.aliases)

Notably:

<kbd>ctrl</kbd>+<kbd>s</kbd> --> `source ~/.zshrc`

<kbd>ctrl</kbd>+<kbd>g</kbd> --> lazygit

<kbd>ctrl</kbd>+<kbd>h</kbd> --> helix editor

<kbd>enter</kbd> [zsh-magic-dashboard](https://github.com/chrisgrieser/zsh-magic-dashboard)

<img width="1360" alt="image" src="https://github.com/user-attachments/assets/fa4040d8-ce6d-4b6e-b3dd-0a0179f4f115">

[nav](https://github.com/betafcc/nav) arrow keys: 
`alt` + `↑` - go up a directory
`alt` + `↓` - fuzzy find directory below current one
`alt` + `←` - go back in directory history
`alt` + `→` - go forward in directory history

## utilities: [shell functions](https://github.com/adriangalilea/dotfiles-rpi/blob/master/.shell/.functions)

### [`sys`](https://github.com/adriangalilea/dotfiles-rpi/blob/92afee4de28aa5e26dffc438d71364bd00f50998/.shell/.functions#L62)
<img width="260" alt="image" src="https://github.com/user-attachments/assets/59c06811-b290-4351-a6e4-c3e91c4ec1b4">

### [`dif`](https://github.com/adriangalilea/dotfiles-rpi/blob/92afee4de28aa5e26dffc438d71364bd00f50998/.shell/.functions#L154)

<img width="765" alt="image" src="https://github.com/user-attachments/assets/af434b5f-908d-4945-bec0-8459d3b1a54f">


```
» dif -h                                                                                                            
Usage: dif <file1> <file2>
Compare two files or URLs, including GitHub repositories.

Supported formats:
  - Local files
  - GitHub shorthand: git:{repo}:{[optional, default=main/master]branch}:{filepath}
    ex: git:adriangalilea/dotfiles-rpi:.shell/.aliases
  - GitHub regular URLs: https://github.com/adriangalilea/dotfiles-rpi/blob/master/.shell/.aliases
  - GitHub raw URLs: https://raw.githubusercontent.com/adriangalilea/dotfiles-rpi/master/.shell/.aliases

Examples:
  1. Compare local file to GitHub shorthand:
     dif ~/.shell/.aliases git:adriangalilea/dotfiles-rpi:.shell/.aliases

  2. Compare two GitHub repositories using shorthand:
     dif git:adriangalilea/dotfiles-rpi:.shell/.aliases git:sobolevn/dotfiles:shell/.aliases

  3. Compare GitHub shorthand to GitHub regular URL:
     dif git:adriangalilea/dotfiles-rpi:.shell/.completions https://github.com/sobolevn/dotfiles/blob/master/shell/.completions

  4. Compare local file to GitHub raw URL:
     dif ~/.shell/.completions https://raw.githubusercontent.com/sobolevn/dotfiles/master/shell/.completions

  5. Compare GitHub regular URL to GitHub raw URL:
     dif https://github.com/adriangalilea/dotfiles-rpi/blob/master/.shell/.aliases https://raw.githubusercontent.com/sobolevn/dotfiles/master/shell/.aliases

  6. Compare two local files:
     dif ~/.shell/.aliases ~/.shell/.completions

  7. Compare GitHub shorthand with specific branch to GitHub regular URL:
     dif git:adriangalilea/dotfiles-rpi:main:.shell/.aliases https://github.com/sobolevn/dotfiles/blob/master/shell/.aliases
```

# [@self] SSH Configuration Instructions

> [!NOTE]  
> This is meant so that I can push from the device to github repo's may not be necessary or desired by you.

To configure SSH for seamless Git operations with GitHub, follow these steps:

1. **Generate SSH Keys:**

```sh
ssh-keygen -t rsa -b 4096 -C "adriangalilea"
```

2. **Add SSH Key to SSH Agent:**

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

3. **Add SSH Key to GitHub:**
  ```sh
  cat ~/.ssh/id_rsa.pu
  ```

   Copy the key and add it to your GitHub account:
   - GitHub: [Settings -> SSH and GPG keys -> New SSH key](https://github.com/settings/keys)

# TODO

## main

- [ ] chore: test install from scratch
- [ ] feat: `.setup` -> `~/.config/setup` & `.shell` -> `~/.config/shell`
- [ ] feat: git highilght in yazi
- [ ] feat: slimmer navigation in yazi
- [ ] merge with my own dotfiles and have just a single source of truth .setup/mac .setup/rpi
- [ ] feat: shell prompt that has username + hostname IF ssh session, otherwise username
- [ ] add: calendar view for my tasks
  - [ ] [`calcurse`](https://calcurse.org/)
  - [ ] [`calcure`](https://github.com/anufrievroman/calcure)
- [ ] showcase:
  - [ ] flow of installation
  - [ ] usefulness
  - [ ] aliases walkthrough
  - [ ] git secret usage to use ai and lsp-ai
  
## side-quests 
- [ ] [research more zsh config](https://github.com/changs/slimzsh?tab=readme-ov-file#fasd)
- [ ] mod [`betafcc/nav`](https://github.com/betafcc/nav) nav-down into fzf like @sobolevn does, works way better
- [ ] taskwarrior
  - [ ] client
  - [ ] server
- [ ] run lsp's in another computer on the network for the zero's
- [ ] feat: github-rsolver or `gr`

# Notes on selected software

## Navigation

After many considerations I settled between `broot` and `yazi`, I genuinely love broot, I think it has the best design, but it's not playing well with my `~` as a git repo and despite feeling slower with `yazi` is offering me enough right now.

> Perfection is the enemy of good.

So I shall stick with `yazi` for now but I urge you to check out `broot`
