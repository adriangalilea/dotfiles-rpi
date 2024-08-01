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
  cat ~/.ssh/id_rsa.pub
  ```

   Copy the key and add it to your GitHub account:
   - GitHub: [Settings -> SSH and GPG keys -> New SSH key](https://github.com/settings/keys)
  
4. Test SSH Connection

```sh
ssh -T git@github.com
```

You should see a message like: "Hi username! You've successfully authenticated, but GitHub does not provide shell access."

5. Update Repository Remote URL

If your repository is currently using HTTPS, update it to use SSH:

```sh
git remote set-url origin git@github.com:username/repository.git
```

Replace 'username' and 'repository' with your GitHub username and repository name.

## Troubleshooting

If you're still having issues:

1. Ensure correct SSH key permissions:
   ```sh
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   ```

2. Add your SSH key to the ssh-agent again:
   ```sh
   ssh-add -K ~/.ssh/id_rsa
   ```

3. Create or edit `~/.ssh/config`:
   ```
   Host github.com
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_rsa
   ```

# Useful tools that I did not install yet:
- https://github.com/reemus-dev/gitnr gitignore generation TUI
