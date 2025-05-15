#!/bin/bash

hyprctl binds -j | jq -r 'map({modkey:.modmask|tostring,key:.key,description:.description,dispatch:.dispatcher,arg:.arg}) | map(.modkey |= {"0":"","1":"SHIFT","4":"CTRL","5":"SHIFT+CTRL","64":"SUPER","65":"SUPER+SHIFT","68":"SUPER+CTRL","72":"SUPER+ALT","73":"SUPER+ALT+SHIFT", "8":"ALT", "12":"ALT+CTRL"} [.] )| sort_by(.modkey)' | jtbl -n --fancy | fzf --layout=reverse-list

