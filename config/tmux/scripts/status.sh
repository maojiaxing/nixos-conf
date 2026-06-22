#!/usr/bin/env bash

CAP_BG="#3e4452"
TEXT_GRAY="#565f89"
TEXT_WHITE="#7dcfff"

left_capsule="#[fg=${CAP_BG},bg=default]#[bg=${CAP_BG}] "
windows=$(tmux list-windows -F '#{window_id}:#{window_active}')
first=true
while read -r w; do
    active=$(echo "$w" | cut -d':' -f2)
    if [ "$first" = true ]; then 
	    first=false; 
    else 
	    left_capsule="${left_capsule}#[fg=${TEXT_GRAY},bg=${CAP_BG}]   "; 
    fi
    if [ "$active" = "1" ]; then 
	    left_capsule="${left_capsule}#[fg=${TEXT_WHITE},bold]"; 
    else 
	    left_capsule="${left_capsule}#[fg=${TEXT_GRAY}]"; 
    fi
done <<< "$windows"
left_capsule="${left_capsule} #[bg=${CAP_BG}] #[fg=${CAP_BG},bg=default]"

tmux set-option -g status-left "${left_capsule}"
