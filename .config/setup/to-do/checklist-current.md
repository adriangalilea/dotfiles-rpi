# Kanban Board

Rules:
1. Three columns: PENDING, DOING, BLOCKED, DONE
2. Tasks have urgency labels [NEXT], [HIGH], [MEDIUM], [LOW]
3. Only one task (and its subtasks) in DOING
4. Periodically clear DONE tasks.
  4.1. Clean the DONE section.
  4.2. Determine what from the removed tasks, warrant a mention in the `checklist.md` file, and add it there as completed.

## PENDING (ordered by urgency)

- [NEXT] template should have a specific target system, e.g.: `{ OS: "Linux", arch: "aarch64" }` just so I can't ever accidentally install something for an unintended system.
- [HIGH] template should accept brew
- [HIGH] fix broot install
  - [ ] github/utils.zsh should handle broot that is a zip file in which inside there is all binaries, and should perform the version selection after the zip is unzipped not before on github curl, but solution should be generic enough
- [MEDIUM] taskwarrior
  - [ ] server
  - [ ] client
- [MEDIUM] print pipx packages that were installed
- [MEDIUM] print apt packages that were installed
- [LOW] use gum to let me choose which steps to proceed, even with sub-items.
- [LOW] [github] track installed versions, so we can check for updates.

## DOING

## BLOCKED (until)

## DONE

