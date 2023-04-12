#!/usr/bin/env fish

# copy to old dir by using mv stuff $od
# trap runs the command when it traps the bash exit signal
function tmp -d "create temp dir and delete it when terminating subshell"
    set -x od $(pwd)
    set -x tmpd $(mktemp -d)

    set -l del
    if type -q trash-put
        set del trash-put
    else
        set del rm -rf
    end

    cd $tmpd
    echo 'Exported variables $od='"$od"' & $tmpd='"$tmpd"

    # trap doesn't work as of fish 3.6.0
    # trap "rm -rf $tmpd; trap 0  # 0 or EXIT
    $SHELL -l
    # $last_pid is the PID of last background process, but the new shell is not
    # run in background
    # there's also --on-signal, --on-event
    # function _exit --on-process-exit $last_pid --inherit-variable del
    function _exit --on-event imdone --inherit-variable del
        $del $tmpd
        cd $od
    end
    emit imdone
end

function cpf -d "copy and follow"
    cp $argv && cd $argv[-1];
end

function mvf -d "move and follow"
    mv $argv && cd $argv[-1];
end

function mkf -d "make and follow"
    mkdir -vp $argv && cd $argv[-1];
end

# add all emacs-mode bindings to vi-mode
# https://fishshell.com/docs/current/interactive.html#vi-mode-commands
function fish_user_key_bindings
    # Execute this once per mode that emacs bindings should be used in
    fish_default_key_bindings -M insert

    # Then execute the vi-bindings so they take precedence when there's a conflict.
    # Without --no-erase fish_vi_key_bindings will default to
    # resetting all bindings.
    # The argument specifies the initial mode (insert, "default" or visual).
    fish_vi_key_bindings --no-erase insert
end
