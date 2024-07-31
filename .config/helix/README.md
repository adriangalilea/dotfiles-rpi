# Helix

## cheat

[config.toml](./config.toml)

```
< unindent
> indent

C-j move line/s down
C-k move line/s up

A-; jump between 2 ends of selection.

A-o tree expand selection
A-i tree shrink selection
A-p jump to prev sibling
<!-- A-n jump to next sibling -->


# Navigation
g-w jump commands
```

## things I'd like to learn more about

- function navigation

# AI

## My thoughts

Helix devs refuse to accept [my proposal of "text suggestion" support](https://github.com/helix-editor/helix/discussions/10259)

__ text suggestion aka virtual text aka ghost text __

I love Helix and I don't envy the mantainers, I just don't think this can be solved with plugins.

> I want to either make a "git blame" or "copilot suggestion" plugin - but both of them make use of some kind of ghost text and I've tried searching for it but cannot find a way to make ghost text.
[@merisbahti comment](https://github.com/helix-editor/helix/pull/8675#issuecomment-2235850288)

but hopefully they change they mind and expose the "virtual text" API so plugins can use em.

In the meantime: 

## [lsp-ai](https://github.com/SilasMarvin/lsp-ai)

Doesn't support copilot = $$$

## [helix-gpt](https://github.com/leona/helix-gpt)

Doesn't work great, finiky and the `helix-gpt.js` is a weird 1 line of js, sounds sketchy, but maybe is because something compiles to it, idk.

- [ ] check if legit or suspicious
- [ ] troubleshoot

could try
```
[language-server.gpt]
command = "helix-gpt"
environment = { HANDLER= "copilot" }
```

which was working for me before with the fix propose on [this issue](https://github.com/leona/helix-gpt/issues/49)

## using zellij yazi lazigit workflow

# TODO

- [ ] Using pipes for AI
  - [ ] learn how to use pipes
  - [ ] mods
    - [ ] system prompt that limits output to only the returning stuff, 0 extra.
    - [ ] can be improved by fine-tuning
    - [ ] can be improved by wrapping it with xml tags and allowing <thinking></thinking>
  - [ ] claude-engineer

## Learn
- [ ] function navigation without tree-sitter
- [ ] navigate between diagnostics faster than space-d for auto applying in batch mode

## check
- [ ] [simple-completion-language-server](https://github.com/estin/simple-completion-language-server)
