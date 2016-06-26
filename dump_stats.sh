#!/usr/bin/env bash

# For each commit in the dissertation, run "texcount" to count how many words
# are present.

orig_repo="$HOME/mers/git/dissertation"
repo="$(pwd)/diss"

# Checkout a local copy
rm -rf "$repo"
git clone --no-hardlinks "$orig_repo" "$repo"
pushd "$repo"

# Run texcount for each commit
# git rebase --exec 'ls > ../$(git describe --always).ls' --root
for rev in $(git rev-list --all); do
    git checkout --quiet "$rev"
    # The first few commits don't have a "manuscript" directory, so this checks
    # for the directory existence to prevent failure of the globbing
    if [[ -d "manuscript" ]]; then
        texcount -total -brief manuscript/*.tex > ../"$rev".stat
    fi
done

# Note the timestamp for each commit
git log --no-abbrev-commit --pretty=format:"%H %ai" > ../timestamps.list

# All done
popd
rm -rf "$repo"
