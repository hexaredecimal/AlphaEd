#!/usr/bin/env bash

buffer=() # File contents
line=0 # Currently selected line (0 means the buffer is empty)
base=1 # Top-most line shown
file= # Currently addressed file
message="AlphaEd: (press 'q' to quit)." # Feedback text in the status bar
modified=false # Tracking whether a file was modified

#shopt -s extglob # Ensure advanced pattern matching is available
#shopt -s checkwinsize; (:) # Enable and then trigger a terminal size refresh
trap redraw WINCH ALRM # Attach WINCH and ALRM to redraw the screen
trap die EXIT HUP USR1 # Attach most exit codes to cleanup and exit
trap quit INT

## set home path
HOME=/storage/emulated/0/





slice()
{
	start=$1
	end=$2
	_ret=()
	
	while [ $((start < end)) -eq 1 ]
	  do
	      _ret+=$(echo ${buffer[$(expr start)]} ) && ((start++))
	  done
	  
	  echo ${_ret[@]}
}




set_buffer_file() {
   # bind 'set disable-completion off' 2>/dev/null # Enable completion
    printf '\e[?25h' # Enable curso
    printf "%s" "${BED_FILE_PROMPT:=Select buffer path($HOME):}" 
    if read -r file; then
        file=$HOME/$file
        modified=true
    fi
    bind 'set disable-completion on' 2>/dev/null
}

read_buffer() {
    set_buffer_file "$1" # Update target file (pass on default if present)
  #  mapfile -t -O 1 buffer <"$file" # Read file into an array
    buffer=("")
 #   buffer=( "$(cat $file)"  )
    IFS=$'\n' 
    while read ln
    do
       buffer+=( "$ln" )
    done  < $file
 
    if [[ "${#buffer[1]}" -gt 0  ]]
       then # Ensure that something was actually read into the file
        line=1 # Indicate that we have a buffer loaded
        modified=false
        message="Read ${#buffer[@]} lines from '$file'"
    else
        message="'$file' is empty"
    fi
}

write_buffer() {
    true >"$file" # Set the file to an empty text file
    for ln in ${buffer[@]} ; do # Write in the buffer to the file
        echo $ln >>"$file"
    done
    modified=false
    message="Wrote ${#buffer[@]} lines to '$file'"
}

get_help() {
    #man bed || message="Failed to get help"
    clear && clear
    
    cat resources/AHelp.txt

    read -r "Press any key to close this help" h
   


}

cmd_line() {
    cd #goto home
    sh #create a command line 
}


new_file()
{
   buffer=()
   file=""
   message="buffer cleaned" 
   modified=false
   line=0 #reset line to null
   redraw
}

edit_line() {
    ((line == 0)) && return # If the line is not possible, do nothing
    printf '\e[?25h\e[%sH' "$((line + 2 - base))" # Reset cursor position and enable cursor
    printf "%4s " $line
   
    
   IFS=$'\0' 
   read -r REPLY # Present editable line
   
        
    if [[ $REPLY != ${buffer[line]} ]]; then # If the line is changed, update and inform
        buffer[line]=$(echo $REPLY)
        modified=true
    fi
    
   down
    
}

new_line() {
    #buffer=$(("" "${buffer[@]:1:line}" "" "${buffer[@]:line+1}"))
   # buffer=$((  "$(echo $(slice 1 $(expr $line)))" "" "$echo($(slice $(expr $line) $((line + 2))))"  ))
    buffer=$(  printf "%s\n" ${buffer[@]}  )
   # unset 'buffer[0]'
    modified=true
}

append_line() {
    new_line
    down
    redraw
    edit_line
}

delete_line() {
    buffer=("" "${buffer[@]:1:line-1}" "${buffer[@]:line+1}")
    unset 'buffer[0]'
    ((line > ${#buffer[@]})) && up
    modified=true
}

quit() {
    if [[ "$modified" == "true" ]]; then
        while :; do
            read -rsN1 -p "Buffer modified, save before close? [Y/n/c]" choice
            case "$choice" in
            Y|y) write_buffer; die;;
            N|n) die;;
            C|c) message="Quit canceled"; break;;
            *) continue;;
            esac
        done
    else
        die
    fi

   #print a new line at the end
   printf "\n" 
}

up() {
    _i=0
   # for ((i = 0; i < ${1:-1}; i++));
   while [ $(( _i < ${1:-1})) -eq 1 ]
    do
        ((line > 1)) && ((line--)) # As long as we can keep going up, go up
        ((line < base)) && ((base--)) # Push back the top if we need to
        ((base <= 0)) && base=1 # Don't push back if our base is at 1
    	((_i++))
     done
}

page_up() {
    up $((LINES - 3))
}

down() {
   # for ((i = 0; i < ${1:-1}; i++));
   j=0
   while [ $(( j < ${1:-1} )) -eq 1 ] 
   do
        ((line < ${#buffer[@]})) && ((line++)) # If we can go down, go down
        ((line > base + LINES - 3)) && ((base++)) # Move window down if needed
    	((j++))
    done
}

page_down() {
    down $((LINES - 3))
}

die() {
    #bind 'set disable-completion off' 2>/dev/null # Enable completion
    printf '\e[?25h\e[?7h\e[?1047l' # Reset terminal to sane mode
    exit "${errno:-0}" # Assume that we're exiting without an error
    exit 
}

redraw() {
    (printf '\e[H\e[?25l\e[100m%*s\r %s \e[41;30m %s \e[0;100m Line:%s Words:%s\e[m' \
        "$COLUMNS" "$message" "${BED_ICON:=∆ }" \
        "$(basename "$file")" "$line" "${#buffer[line]}") # Status line, among others
   
    # for ((i = base; i - base < LINES - 2; i++)); 
    i=$base 
    
    while [ $((i - base)) -lt $((LINES - 2)) ]
    do # Iterate over shown lines
        ((i != line)) && printf '\e[90m' # Fade line number if not selected
        ((i > ${#buffer[@]})) && printf '\n\e[K   ~\e[m' || \
            printf '\n\e[K%4s\e[m %s' "$i" "${buffer[i]}" # Print the line
   	((i++))
    done
    printf '\n' # Add final newline to seperate commandline

    
}

key() {
    case "$1" in
    ${BED_KEY_PGUP:=$'\E[5~'}) page_up;;
    ${BED_KEY_PGDN:=$'\E[6~'}) page_down;;
 
    ${BED_KEY_UP:=w}) up;;
    ${BED_KEY_DOWN:=s}) down;;
    ${BED_KEY_HELP:=h}) get_help;; # Open the manpage (breaks stuff)
    ${BED_KEY_QUIT:=q}) quit;;
    ${BED_KEY_FILE:=f}) set_buffer_file;;
    ${BED_KEY_READ:=r}) read_buffer;;
    ${BED_KEY_WRITE:=g}) write_buffer;;
    ${BED_KEY_EDIT:=e}|'') edit_line;;
    ${BED_KEY_APPEND:=a}) append_line;;
    ${BED_KEY_DELETE:=d}) delete_line;;
    ${BED_KEY_NEW:=n}) new_line;;
    ${BED_KEY_CMD:=c}) cmd_line;;
    ${BED_KEY_NEW_FILE:=m}) 
      new_file;;
    esac
}

main() {
    printf '\e[?1047h' # Switch to alternative buffer
    if [[ "$1" ]]; then # If a file was provided in the terminal pre-load it
        redraw # Draw out the UI before loading file
        read_buffer "$1"
    fi
    while redraw; do # Keep redrawing when we can (allow WINCH signals to get handled)
        k=()
        i=1
        if read -rsN1 -t"${BED_REFRESH_TIMEOUT:=0.1}" k[0]; then # Check for ready input
            while read -rsN1 -t0.0001 k[$i]; do ((i++)); done # Multibyte hack
            key "$(printf '%s' "${k[@]}")" # Handle keypress event
        fi
    done
}

main "$@"
