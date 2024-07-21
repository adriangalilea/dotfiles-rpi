# RPi dotfiles

[This git repo is meant to be used as home `~`.](https://drewdevault.com/2019/12/30/dotfiles.html)

This repo is an attempt to have sane defaults for the various rpi's I have, the idea is to run the main.py as a boot script and have the very same environment in every rpi I flash.

Heavily inspired by [@sobolevn](https://github.com/sobolevn) [dotfiles](https://github.com/sobolevn/dotfiles) with many modifications, also merged my own dotfiles, tailored for the RPi's.

Assumes aarch64.

# Batteries included

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

# TO-DO

## main

- [ ] feat: github-rsolver or `gr`
- [ ] feat: alias that executes `~/.setup/main.sh` for convenience on first git pull
- [ ] refactor: all github installs into [`dra`](https://github.com/devmatteini/dra)
- [ ] chore: test install from scratch
- [ ] chore: move all `pip` installs into `pipx`
- [ ] feat: shell prompt that has username + hostname IF ssh session, otherwise username
- [ ] add: `direnv`
- [ ] add: `markdown-oxide` lsp for hx
- [ ] add: `calcurse`
- [ ] fix `zoxide` not behaving right if set in alias as `cd` 
- [ ] consider if [sdm](https://github.com/gitbls/sdm) or hijacking the script.sh(rpi imager) is a better option to run the `setup.sh`
- [ ] improve installing output:
```
  » ./main.sh
Installing gum...
Adding Charm repository...
Charm GPG key already exists. Skipping addition.
Charm repository process completed.
Hit:1 http://deb.debian.org/debian bookworm InRelease
Hit:2 http://deb.debian.org/debian-security bookworm-security InRelease                                                 
Hit:3 http://deb.debian.org/debian bookworm-updates InRelease                                                           
Hit:4 http://deb.gierens.de stable InRelease                                                  
Hit:5 http://archive.raspberrypi.com/debian bookworm InRelease                                
Get:6 https://repo.charm.sh/apt * InRelease                             
Fetched 6,639 B in 3s (2,039 B/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
3 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  gum
0 upgraded, 1 newly installed, 0 to remove and 3 not upgraded.
Need to get 0 B/4,222 kB of archives.
After this operation, 28.3 MB of additional disk space will be used.
Selecting previously unselected package gum.
(Reading database ... 124307 files and directories currently installed.)
Preparing to unpack .../archives/gum_0.14.1_arm64.deb ...
Unpacking gum (0.14.1) ...
Setting up gum (0.14.1) ...
Processing triggers for man-db (2.11.2-2) ...
INFO gum installed successfully. Running system setup... <-- cooler glasses emoji
INFO Starting setup...
WARN Current swap size (1024 MB) is already greater than or equal to requested size (1024 MB). Skipping. <-- memory emoji
INFO Installing required packages...
INFO Updating package lists...
INFO Package lists updated successfully.
INFO Installing APT packages... <-- needs same output as github installed packages
INFO APT packages installed successfully.
INFO Installing pip packages...
INFO Pip packages installed successfully. <-- needs same output as github installed packages
📦 helix 🌐 helix-editor/helix 🏷️  was installed! ✅
📦 eza 🌐 eza-community/eza 🏷️  was installed! ✅
📦 lazygit 🌐 jesseduffield/lazygit 🏷️  was installed! ✅
📦 gdu 🌐 dundee/gdu 🏷️  was installed! ✅
📦 fzf 🌐 junegunn/fzf 🏷️  was installed! ✅
📦 delta 🌐 dandavison/delta 🏷️  was installed! ✅
📦 vale 🌐 errata-ai/vale 🏷️  was installed! ✅
📦 vale-ls 🌐 errata-ai/vale-ls 🏷️  was installed! ✅
INFO Clipboard forwarding set up and SSH service restarted.
INFO Setup complete! Please reboot to apply all changes. <-- needs emoji ✅
19 Jul 24 22:22 CEST INFO Setup finished at Fri 19 Jul 22:22:01 CEST 2024 <-- redundant
````
- [ ] handle lack of gum or opt-out
- [ ] .toml file to select installing packages on each category instead of main.py
- [ ] refactor: github utils and github.sh inside /github
- [ ] "
- [ ] showcase:
  - [ ] flow of installation
  - [ ] usefulness
  - [ ] aliases walkthrough
  - [ ] git secret usage to use ai and lsp-ai
- [ ] merge with my own dotfiles and have just a single source of truth .setup/mac .setup/rpi
  
## side-quests 
- [ ] [simple-completion-language-server](https://github.com/estin/simple-completion-language-server) + [lsp-ai](https://github.com/SilasMarvin/lsp-ai)
- [ ] [research more zsh config](https://github.com/changs/slimzsh?tab=readme-ov-file#fasd)
- [ ] mod [`betafcc/nav`](https://github.com/betafcc/nav) nav-down into fzf like @sobolevn does, works way better
- [ ] more architectures
- [ ] interactive installs
- [ ] taskwarrior
  - [ ] client
  - [ ] server
- [.] add [yallezix v3](https://github.com/luccahuguet/zellij) for a tree navigation and possible integration with other tools such as task-warrior tui
