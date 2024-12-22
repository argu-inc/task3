#!/bin/bash

N=""
minsize=1
human_readable=false
dirs=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h)
            human_readable=true
            shift
            ;;
        -N)
            shift
            if [[ $# -gt 0 && $1 =~ ^[0-9]+$ ]]; then
                N=$1
                shift
            else
                exit 1
            fi
            ;;
        -s)
            shift
            if [[ $# -gt 0 && $1 =~ ^[0-9]+$ ]]; then
                minsize=$1
                shift
            else
                exit 1
            fi
            ;;
        --)
            shift
            break
            ;;
        *)
            dirs+=("$1")
            shift
            ;;
    esac
done

if [[ ${#dirs[@]} -eq 0 ]]; then
    dirs=(".")

fi

find_cmd="find ${dirs[@]} -type f -size +${minsize}c -printf '%s %p\n'"

if $human_readable; then
    eval "$find_cmd" | sort -nr | awk "{
        size = $1;
        path = $2;
        for(i=3; i<=NF; i++) {
            path = path " " $i;
        }
        if (size >= 1024) {
            printf "%.2fK %s\n", size/1024, path;
        } else {
            printf "%dB %s\n", size, path;
        }
    }" | ${N:+head -n $N}
else
    eval "$find_cmd" | sort -nr | head ${N:+-n $N}
fi
