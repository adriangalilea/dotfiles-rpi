# Kanban Board

Rules:
1. Three columns: PENDING, DOING, BLOCKED, DONE
2. Tasks have urgency labels [NEXT], [HIGH], [MEDIUM], [LOW]
3. Only one task (and its subtasks) in DOING
4. Periodically clear DONE tasks.
  4.1. Clean the DONE section.
  4.2. Determine what from the removed tasks, warrant a mention in the `checklist.md` file, and add it there as completed.

## PENDING (ordered by urgency)

- [NEXT] make all the requirements installs cross-platform.
- [ ] print pipx packages that were installed
- [ ] print apt packages that were installed
- [ ] use gum to let me choose which steps to proceed, even with subitems. 
- [ ] ```❯ ./main.zsh rpi_aarch64.cue
03:13:37 DEBUG /home/adrian/.config/setup/log: Executed by adrian

03:13:38 INFO Installing requirements...
03:13:38 DEBUG install_requirements: gum is already installed.
03:13:38 DEBUG install_requirements: cue is already installed.```

order is incorrect
- [MEDIUM] fix broot install
  - [ ] github/utils.zsh should handle broot that is a zip file in which inside there is all binaries, and should perform the version selection after the zip is unzipped not before on github curl, but solution should be generic enough
- [LOW] taskwarrior
  - [ ] server
  - [ ] client

## DOING

## BLOCKED (until)

## DONE

