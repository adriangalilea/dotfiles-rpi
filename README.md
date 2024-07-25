# `~` <--> git

[This git repo is your home, literally.](https://drewdevault.com/2019/12/30/dotfiles.html)

Easily track down dotfiles without requiring any dependency besides git.

Merged all the tools that I curated for Mac and Linux into these dotfiles.

Heavily inspired by [@sobolevn](https://github.com/sobolevn) [dotfiles](https://github.com/sobolevn/dotfiles) with many modifications.

> [!WARNING]  
> WIP
>
> Yet to be tested in a fresh install from scratch.
> If you decide to use any of the scripts here, you do it on your own, I'm not responsible, feel free to check and judge on your own.
> `.config` dotfiles are stable. 
# Batteries included

1. [`~/.config/setup`](./.config/setup): automated install of software & system config.

2. [`~/.config/shell/utils`](./.config/shell/utils)

3. Custom [MOTD](./.config/motd) (Message Of The Day --> the message ssh greets you with)

4. [Helix editor config](./.config/helix) + [Zellij config(WIP)](./.config/zellij)

5. [`~/.config/shell/functions`](./.config/shell/functions)

6. [`~/.config/shell/aliases`](./.config/shell/aliases)

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

# TODO

## main

- [ ] chore: test install from scratch
- [ ] merge with my own dotfiles and have just a single source of truth .config/setup/mac .config/setup/rpi
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
