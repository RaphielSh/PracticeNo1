#!/bin/bash

#help func
help() {
    echo "Usage: $(basename "$0") [args]"
    echo "Args:"
    echo " -u, —users     Show users and their home dirs"
    echo " -p, —processes Show processes(sorted by PID)"
    echo " -h, —help      Get manual"
    echo " -l [path], —log [path]  Redirect output to file in [path]"
    echo " -e [path], —errors [path]  REdirect errors to file in [path]"
}

#Show users func
show_users() {
    getent passwd | awk -F: '$3 >= 1000' | sort -t: -k1,1 | awk -F: '{print "User:", $1, "Home dir:", $6}'
}

# Show processes func
show_processes(){ 
    ps -eo pid,cmd --sort=pid 
}

# redirect output
redirect_output() {
    local path=$1
    if ! touch "$path" 2>/dev/null; then
        echo "Unable to write in $path" >&2
        exit 1
    fi
    exec > "$path"
}

# redirect errors
redirect_errors() {
    local path=$1
    if ! touch "$path" 2>/dev/null; then
        echo "Unable to write(errors) $path" >&2
        exit 1
    fi
    exec 2> "$path"
}

# Command proccessing
while getopts ":uphl:e:-:" opt; do
    case $opt in
        u|users)
            show_users
            ;;
        p|processes)
            show_processes
            ;;
        h|help)
            help
            exit 0
            ;;
        l|log)
            redirect_output "$OPTARG"
            ;;
        e|errors)
            redirect_errors "$OPTARG"
            ;;
        -)
            case "${OPTARG}" in
                users)
                    show_users
                    ;;
                processes)
                    show_processes
                    ;;
                help)
                    help
                    exit 0
                    ;;
                log)
                    redirect_output "${!OPTIND}"
                    OPTIND=$((OPTIND + 1))
                    ;;
                errors)
                    redirect_errors "${!OPTIND}"
                    OPTIND=$((OPTIND + 1))
                    ;;
                *)
                    echo "Unknown command(arg) —$OPTARG" >&2
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "Unknown command(arg) -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# No command entried
if [[ $# -eq 0 ]]; then
    help
fi
