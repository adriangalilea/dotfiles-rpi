# Automated install manager

> [!CAUTION]  
> This changes system stuff, be suree you inspected what it does before running.

# Alternatives

## [sdm](https://github.com/gitbls/sdm)

Haven't tested, but I don't miss much yet.

## hijacking the script.sh(rpi imager)

I should ideally try to see if I can make the first install even more hands-off

## [dra](https://github.com/devmatteini/dra)

I concluded that I don't have much to miss in that, didn't work for packages that I did have problems with and did also fail in some that I succeed at.

I also think I can make it even better, but if anyone is looking for a readymade alternative, dra is great, and dev is very active.


# TODO
- [ ] feat: script the install on first rpi boot, hijacking the script.sh perhaps.
- [ ] feat: store the version installed so that we can then eventually check for updates.
- [ ] feat: alias that executes `~/.setup/main.zsh` for convenience on first git pull
- [ ] fix installing `ya` from `yazi` as is the package manager and is blocking:
- [ ] .toml file to select installing packages on each category instead of main.py
- [ ] feat: more architectures
- [ ] feat: interactive installs

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

# Useful tools that I did not install yet:
- https://github.com/reemus-dev/gitnr gitignore generation TUI
