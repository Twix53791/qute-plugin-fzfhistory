#!/bin/bash

_main (){
    cmd=$(command -v sqlite3)
    if [[ -z $cmd ]]; then
        echo "error :: sqlite3 needed. Command not found. Exit"
        exit
    fi

    quteinfos=$(qutebrowser -V)
    qutesrc=$(grep '^Imported from' <<< $quteinfos | cut -d' ' -f3)
    datadir=$(grep '^data:' <<< $quteinfos | cut -d' ' -f2)
    database="$datadir/history.sqlite"

    # Patch the qutebrowser files
    if [[ $1 == "--only-history" ]]; then
        patch "$qutesrc/browser/history.py" -i history.patch

    elif [[ $1 != "--rebuild" ]]; then
        if ! sudo patch "$qutesrc/browser/history.py" -i history.patch; then
            echo "error :: can't patch $qutesrc/browser/history.py. Exit"
            exit
        fi
        if ! sudo patch "$qutesrc/mainwindow/tabbedbrowser.py" -i tabbedbrowser.patch; then
            echo "error :: can't patch $qutesrc/mainwindow/tabbedbrowser.py. Exit"
            exit
        fi
    fi

    # Update history.sqlite database
      # Adding the new column 'human_time' to CompletionHistory table
    existingcols=$(sqlite3 "$database" 'PRAGMA table_info(CompletionHistory)' | cut -d'|' -f2)

    if [[ $existingcols != *human_time* ]]; then
        sqlite3 "$database" 'ALTER TABLE CompletionHistory ADD COLUMN human_time TEXT'
        _rebuild_CompletionHistory_table

    elif [[ $1 == "--rebuild" ]]; then
        _rebuild_CompletionHistory_table
    fi
}

_rebuild_CompletionHistory_table (){
    tmpfile="/tmp/rebuild_CompletionHistory"

    # Store the content of CompletionHistory in a tmp file
    sqlite3 $database "SELECT last_atime FROM CompletionHistory" > $tmpfile

    # Counter to build a progress bar
    ntotal=$(wc -l $tmpfile)
    onepercent=$(echo $((${ntotal%% *} / 100)))
    i=0
    p=0
    echo "Total of rows in CompletionHistory : ${ntotal%% *}"
    echo "==================================="
    echo "$p % done"

    while read atime; do
        # Progress view
        if (($i % ($onepercent + 1) == 0 )); then
            ((p++))
            [[ $p -le 100 ]] && echo "$p % done"
        fi

        # Translate atime in htime
        htime="$(date '+%Y %B %d %H:%M:%S' -d @$atime)"

        # Update the humain_time col
        sqlite3 $database "UPDATE CompletionHistory SET human_time = '$htime' WHERE last_atime = $atime"

        ((i++))
    done < $tmpfile
}

_main "$@"


