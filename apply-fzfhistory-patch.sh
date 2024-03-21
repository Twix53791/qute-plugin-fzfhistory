#!/bin/bash

if [[ $1 == "--only-history" ]]; then
    shift
    patch "$1/browser/history.py" -i history.patch
    patch "$1/mainwindow/tabbedbrowser.py" -i tabbedbrowser.patch
else
    patch "$1/browser/history.py" -i history.patch
fi
