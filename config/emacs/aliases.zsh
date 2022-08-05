#!/usr/bin/env zsh

e()     { pgrep emacs && emacsclient -nw "$@" || emacs -nw "$@" }
ediff() { emacs -nw --eval "(ediff-files \"$1\" \"$2\")"; }
eman()  { emacs -nw --eval "(switch-to-buffer (man \"$1\"))"; }
ekill() { emacsclient --eval '(kill-emacs)'; }
# always create a new X frame
ef()    { pgrep emacs && emacsclient -c -n "$@" || emacs "$@" }
alias et='e'

# edit file with root privs
alias efs="SUDO_EDITOR=\"emacsclient -c -a emacs\" sudoedit"
alias ets="SUDO_EDITOR=\"emacsclient -t -a emacs\" sudoedit"
