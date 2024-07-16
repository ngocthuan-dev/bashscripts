#!/bin/bash

check_is_int_and_greater_than_zero() {
    # $1 is value to check, $2 is name of var
    var_name=${2:-"Input"}
    if [[ ! $1 =~ ^[0-9]+$ || $1 -le 0 ]]; then
        echo "$var_name must be an integer and greater than zero!"
        exit 1
    fi
}

NOTIFICATION_SOUND=Funky
NOTIFICATION_DURATION=5
default_focus_length=25
FOCUS_NOTI_TEXT="Time to get back to work!"
default_break_length=$((default_focus_length / 5))
BREAK_NOTI_TEXT="Time to walk and rest!"

read -p "How long do you want to focus (Default: 25 mins): " var_focus_length
focus_length=${var_focus_length:-$default_focus_length}
check_is_int_and_greater_than_zero "$focus_length" "Focus length"
focus_length_seconds=$((focus_length * 60))
FOCUS_NOTI_TITLE="Focus ($focus_length mins)"

read -p "How long do you want to break (Default: 5 mins): " var_break_length
break_length=${var_break_length:-$default_break_length}
check_is_int_and_greater_than_zero "$break_length" "Break length"
break_length_seconds=$((break_length * 60))
BREAK_NOTI_TITLE="Break ($break_length mins)"

if [[ $(uname) == 'Darwin' ]]; then
    while true; do
        next_break_timestamp=$(($(date +%s) + focus_length_seconds))
        while [[ $next_break_timestamp -ge $(date +%s) ]]; do
            echo -ne "$(date -u -j -f %s $(($next_break_timestamp - $(date +%s))) +%H:%M:%S)\r"
        done
        
        osascript -e "display notification \"$BREAK_NOTI_TEXT\" \
with title \"$BREAK_NOTI_TITLE\" sound name \"$NOTIFICATION_SOUND\""
        read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'

        next_focus_timestamp=$(($(date +%s) + break_length_seconds))
        while [[ $next_focus_timestamp -ge $(date +%s) ]]; do
            echo -ne "$(date -u -j -f %s $(($next_focus_timestamp - $(date +%s))) +%H:%M:%S)\r"
        done
        
        osascript -e "display notification \"$FOCUS_NOTI_TEXT\" \
with title \"$FOCUS_NOTI_TITLE\" sound name \"$NOTIFICATION_SOUND\""
        read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
    done
fi
