# RPi dotfiles

[This git repo is meant to be used as home `~`.](https://drewdevault.com/2019/12/30/dotfiles.html)

This repo is an attempt to have sane defaults for the various rpi's I have, the idea is to run the main.py as a boot script and have the very same environment in every rpi I flash.

Heavily inspired by [@sobolevn](https://github.com/sobolevn) [dotfiles](https://github.com/sobolevn/dotfiles) with many modifications, also merged my own dotfiles, tailored for the RPi's.

Assumes aarch64.

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

- [ ] test install from scratch
- [ ] fix `zoxide` not behaving right if set in alias as `cd` 
- [ ] consider if [sdm](https://github.com/gitbls/sdm) or hijacking the script.sh(rpi imager) is a better option to run the `setup.sh`
  
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
- [ ] port `ip` into a package I can install in linux instead of brew(not workign on arm) > install `ip`
