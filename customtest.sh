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

        echo "./uqparallel $args < "$dirname/input" > $dirname/stdout 2> $dirname/stderr"
    fi
done


temp_dir="tmp"

# Ensure stdout and stderr files exist (they will be created if not)
mkdir -p "$temp_dir"
touch "$temp_dir/stdout" "$temp_dir/stderr"

# Loop through all subdirectories of the specified directory
for dir in "$search_dir"/*/; do
    # Remove trailing slash to get directory name
    dirname="${dir%/}"

    # Check if input.txt and args.txt both exist in the directory
    if [ -f "$dirname/input" ] && [ -f "$dirname/args" ]; then
        # Read the entire content of args.txt as a single argument
        args=$(<"$dirname/args")



        # Execute the command with input redirection and arguments from args.txt
        ./uqparallel $args < "$dirname/input" > "$temp_dir/stdout" 2> "$temp_dir/stderr"

        if [ "$1" == "--valgrind" ]; then
            valgrind --leak-check=full --show-leak-kinds=all ./uqparallel $args < "$dirname/input" > valgrind_output 2>&1

            if grep -q "LEAK" valgrind_output; then
                cat valgrind_output
            fi
        fi



        numOut=$(diff tmp/stdout $dirname/stdout | wc -l)
        numErr=$(diff tmp/stderr $dirname/stderr | wc -l)

        if [ $numOut -ne 0 -o $numErr -ne 0 ]; then
            printf "\e[31m[FAILED]\e[0m | $dirname\n"

            if [ $numOut -ne 0 ]; then
                diff tmp/stdout $dirname/stdout
            else
                diff tmp/stderr $dirname/stderr
            fi
        else
            printf "\e[32m[PASSED]\e[0m | $dirname\n"
        fi

    else
        # Print which directory is skipped if it doesn't have the required files
        echo "Skipping directory $dirname - missing input.txt or args.txt"
    fi
done

rm -rf "$temp_dir"
