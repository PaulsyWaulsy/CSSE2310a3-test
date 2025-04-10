#!/bin/bash

# Hardcoded search directory (the root directory to search for subdirectories)
search_dir="test"  # Set this to "test" if that's your directory

# Loop through all subdirectories of the specified directory
for dir in "$search_dir"/*/; do
    # Remove trailing slash to get directory name
    dirname="${dir%/}"

    # Check if input and args both exist in the directory
    if [ -f "$dirname/input" ] && [ -f "$dirname/args" ]; then
        # Read the entire content of args as a single argument
        args=$(<"$dirname/args")


        # Execute the command with input redirection and arguments from args
        touch "$dirname/stdout" "$dirname/stderr"
        demo-uqparallel $args < "$dirname/input" > "$dirname/stdout" 2> "$dirname/stderr"

        echo "Generated output in $dirname"
    fi
done
