# qute-plugin-fzfhistory

Open your history in a fzf menu  
Open in fzf the history of the last 100 recently closed tabs

## Installation
### Dependencies
The installation process need `sqlite3` installed. If you want to use another sqlite tools, edit the scripts or create the column 'human_time' in the table 'CompletionHistory' by yourself...

```
git clone https://github.com/Twix53791/qute-plugin-fzfhistory/
cd qute-plugin-fzfhistory
./apply-fzfhistory-patch.sh
cp fzfhistory-userscript ~/.config/qutebrowser/userscripts/
cp qute-plugin-fzfhistory ~/config/qutebrowser/bin/
```

* `apply-fzfhistory-patch.sh` update the history.sqlite qutebrowser database to add the time in a human readable format.
* **edit `fzfhistory-userscript` to fit your config. I use for example `kitty` as a terminal, but maybe not you...**
* `qute-plugin-fzfhistory` can be copied in any bin path, for example /usr/local/bin. I have created a bin folder in qutebrowser config I added to my bin path in .zshrc (or .bashrc), but you can use your own setup.
* **If you don't want to use the 'closed-tabs' extension but only the normal qutebrowser history, run `./apply-fzfhistory-patch.sh --only-history`**

## Use
In `config.py`:
```
'h': 'spawn -u fzfhistory-userscript',
'H': 'spawn -u fzfhistory-userscript closed-tabs',
```

### Structure
`fzfhistory-userscript` run a termminal window (I recommand to make it floating for example in your window manager rules), running the command `qute-plugin-fzfhistory` which displays the content of the table `CompletionHistory` of history.sqlite. This table has been updated with a new column 'human_time' by `apply-fzfhistory-patch.sh`, and now, the patched history.py file in qutebrowser source code add the time also in a human readable format to the urls stored in the history.

## Rebuild the CompletionHistory table
To apply the changes in the recording of the history (with now a human readable time format) to your past history, 'apply-fzfhistory-patch.sh' update the history.sqlite database. In case of any problem, to reset the CompletionHistory table:  
`sqlite3 ~/.local/share/qutebrowser/history.sqlite 'ALTER TABLE CompletionHistory DROP human_time'`  
Then run `./apply-fzfhistory-patch.sh --rebuild` OR `qute-plugin-fzfhistory rebuild`.
