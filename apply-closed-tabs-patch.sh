#!/bin/bash
# Enables the 'close-tabs' extension of qute-plugin-fzfhistory

quteinfos=$(qutebrowser -V)
qutesrc=$(grep '^Imported from' <<< $quteinfos | cut -d' ' -f3)

# Patch the qutebrowser files
if ! sudo patch "$qutesrc/mainwindow/tabbedbrowser.py" -i tabbedbrowser.patch; then
    echo "error :: can't patch $qutesrc/mainwindow/tabbedbrowser.py. Exit"
    exit
fi

