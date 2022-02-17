#!/bin/bash

# backup stuff in my projects folder

#todo: 
# - make proper use of git plumbing commands
# - detect hard drive and copy non-git repos to it
# - collate array of remote repo urls to clone and write to file

cd ~/Projects

for dir in *; do
    if [[ -e $dir/.git/ ]]; then
        # ignore dotfiles cause if this script is running,
        # we should have already cloned it
        [[ "$dir" == "dotfiles" ]] && continue
        cd $dir
        url=$(git config --get remote.origin.url)
        echo "$dir cloned from $url"
        cd ../
    else
        echo "$dir is not a git repo" 
    fi
done