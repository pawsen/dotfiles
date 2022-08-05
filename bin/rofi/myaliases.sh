#!/usr/bin/env zsh

my_aliases() {
    # for some reason this does not return all the aliases defined
    # NOTE that the emacs shortcuts e, ef, are functions
    # alias | awk -F'[ =]' '{print $1}'

    # special zsh builtins
    #print -rl -- ${(k)aliases} ${(k)functions} ${(k)parameters} | grep "^[^_]"
    # https://superuser.com/a/684256
    print -l ${(ok)functions[(I)[^_\-\+]*]}

}
my_aliases
