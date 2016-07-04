#!/usr/bin/env bash

# For each commit in the dissertation, run "texcount" to count how many words
# are present.

orig_repo="$HOME/mers/git/dissertation"
repo="$(pwd)/diss"
timestamps="$(pwd)/timestamps.list"
word_stats="$(pwd)/word_stats.list"

# Checkout a local copy
rm -rf "$repo"
git clone --quiet --no-hardlinks "$orig_repo" "$repo"
pushd "$repo"

# Note the timestamp for each commit
echo "Recording commit timestamps"
git log --no-abbrev-commit --pretty=format:"%H,%aI" > "$timestamps"

# Run texcount for each commit
echo "Counting words for each commit"
rm -f "$word_stats"
revs=($(git rev-list --all))
i=0
for rev in "${revs[@]}"; do
    ((i++))
    echo "  commit $rev ($i/${#revs[@]})"
    git checkout --quiet "$rev"
    # The first few commits don't have a "manuscript" directory, so this checks
    # for the directory existence to prevent failure of the globbing
    if [[ -d "manuscript" ]]; then
        echo -n "$rev," >> "$word_stats"
        texcount -total -brief manuscript/*.tex >> "$word_stats"
    fi
done

# All done
popd
rm -rf "$repo"
