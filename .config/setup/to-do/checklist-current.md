# Kanban Board

Rules:
1. Three columns: PENDING, DOING, BLOCKED, DONE
2. Tasks have urgency labels [NEXT], [HIGH], [MEDIUM], [LOW]
3. Only one task (and its subtasks) in DOING
4. Periodically clear DONE tasks.
  4.1. Clean the DONE section.
  4.2. Determine what from the removed tasks, warrant a mention in the `checklist.md` file, and add it there as completed.

## PENDING (ordered by urgency)

- [NEXT] feat: eza .local/bin is only aarch64
- [NEXT] ❯ yy
yy:2: command not found: yazi
❯ ya
zsh: command not found: ya
❯ br
br:3: command not found: broot
After having run the installer
- [NEXT] make select right version agnostic, so we can use it for local folders or files.
- [NEXT] select the only zip/tar  w/e that is if there's only  one with generic name then find inside best match, either dir, which means what's inside, or bin directly.
- [NEXT] template should have a specific target system, e.g.: `{ OS: "Linux", arch: "aarch64" }` just so I can't ever accidentally install something for an unintended system.
- [HIGH] add git as requirement.
- [HIGH] improve visibility of what's going on in apt update
- [HIGH] template should accept brew
- [HIGH] fix: 00:46:07 ERROR setup_custom_motd: Custom MOTD script not found at /root/.config/motd/custom_motd.sh
- [HIGH] fix: 00:46:00 ERROR execute_command_step: Error output: Searching for a package manager...  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current                                 Dload  100   731  100   731    0     0    458      0  0:00:01  0:00:01 --:--:--   458Archive:  clipboard-linux.zip  End-of-central-directory signature not found.  Either this file is not  a zipfile, or it constitutes one disk of a multi-part archive.  In the  latter case the central directory and zipfile comment will be found on  the last disk(s) of this archive.unzip:  cannot find zipfile directory in one of clipboard-linux.zip or        clipboard-linux.zip.zip, and cannot find clipboard-linux.zip.ZIP, period.

- [HIGH] fix: 📦 jwtui
Failed to extract version
❌ Skipping jwtui: Failed to process package

📦 csvlens
Failed to extract version
❌ Skipping csvlens: Failed to process package
- [HIGH] fix broot install
  - [ ] github/utils.zsh should handle broot that is a zip file in which inside there is all binaries, and should perform the version selection after the zip is unzipped not before on github curl, but solution should be generic enough
- [HIGH] Place the xdg-dirs install higher up, so that the rest of packages that use XDG `env`'s   generate config files in the right place, such as all `charmbracelet` programs(mods)
- [HIGH] feat: more architectures:
  - [HIGH] Mac m series
  - [LOW] Mac intel series
  - [LOW] Linux non-aarch64
- [MEDIUM] feat: replace the ~/.config/setup/utils/ log function without our log  function
- [MEDIUM] taskwarrior
  - [ ] server
  - [ ] client
- [MEDIUM] feat: alias that executes `~/.setup/main.zsh` for convenience on first git pull
- [MEDIUM] print pipx packages that were installed
- [MEDIUM] print apt packages that were installed
- [MEDIUM] I should expose the github installer script, perhaps make it stand-alone in his own repo.
- [LOW] use gum to let me choose which steps to proceed, even with sub-items.
- [LOW] [github] track installed versions, so we can check for updates.
- [HIGH] feat: script the install on first rpi boot, hijacking the script.sh perhaps.
- [LOW] feat: interactive installs
- [LOW] Things to check-out:
  - [ ] [units](https://www.gnu.org/software/units/)
  - [ ] [qalc](https://github.com/Qalculate/libqalculate)
  - [ ] [trash-cli](https://github.com/andreafrancia/trash-cli)

## DOING

## BLOCKED (until)

## DONE

