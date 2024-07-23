#!/usr/bin/env zsh
files=(${(fqq)"$( yazi --chooser-file=/dev/stdout | cat )"})
zellij action toggle-floating-panes
zellij action write 27 # send escape-key
zellij action write-chars ":open $files"
zellij action write 13 # send enter-key
zellij action toggle-floating-panes
zellij action close-pane
