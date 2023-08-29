#!/bin/bash

# Check if the directory argument is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <edition id>"
    exit 1
fi

# Change to the provided directory
cd "captures/$1" || { echo "Directory $1 not found!"; exit 1; }

# Check if the directory is inside a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "The directory is not inside a Git repository!"
    exit 1
fi

# Iterate through every subdirectory
for subdir in */; do
    # Ensure it's a directory
    if [[ -d "$subdir" ]]; then
        echo "Processing $subdir..."

        # Add all files inside the subdirectory to the git index
        git add "$subdir"* || { echo "Failed to add files in $subdir to git index"; exit 1; }

        # Check if there are any changes staged for commit
        if git diff-index --cached --quiet HEAD --; then
            echo "No changes in $subdir to commit."
        else
            # Commit with the subdirectory name (stripping the trailing slash)
            git commit -m "${subdir%/}" || { echo "Commit for $subdir failed"; exit 1; }

            # Push the changes
            git push || { echo "Push failed for $subdir"; exit 1; }

            echo "$subdir processed successfully!"
        fi
    fi
done

echo "All done!"
