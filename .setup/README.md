# Automated install manager

# Alternatives

## [sdm](https://github.com/gitbls/sdm)

Haven't tested, but I don't miss much yet.

## hijacking the script.sh(rpi imager)

I should ideally try to see if I can make the first install even more hands-off

## [dra](https://github.com/devmatteini/dra)

I concluded that I don't have much to miss in that, didn't work for packages that I did have problems with and did also fail in some that I succeed at.

I also think I can make it even better, but if anyone is looking for a readymade alternative, dra is great, and dev is very active.


# TODO
- [ ] fix installing `ya` from `yazi` as is the package manager and is blocking:
  - [ ] install [relative-motions](https://github.com/dedukun/relative-motions.yazi)
- [ ] more architectures
- [ ] interactive installs
- [ ] .toml file to select installing packages on each category instead of main.py
- [ ] feat: alias that executes `~/.setup/main.sh` for convenience on first git pull
- [ ] script the install on first rpi boot, hijacking the script.sh perhaps.
