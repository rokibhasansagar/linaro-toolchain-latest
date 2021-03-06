#!/bin/bash

git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true

baseAddr="https://releases.linaro.org/components/toolchain/binaries"
branches="latest-4 latest-5 latest-6 latest-7"

for branch in $branches; do
    echo -en "Current branch is -- " && echo $branch
    # build-1, no-check
    echo -e "Getting new file name from release server"
    curl -s "$baseAddr/$branch/aarch64-linux-gnu/" | grep "x86_64_aarch64-linux-gnu.tar.xz" | sort | cut -d , -f3 | tail -n 2 | head -n 1 | awk '{print substr($1,2)}' | sed 's/....$//g' >> $branch-archive-name.txt
    fileName=$(cat $branch-archive-name.txt)
    echo -en "New filename is -- " && echo $fileName
    fileAddr=$baseAddr/$branch/aarch64-linux-gnu/$fileName
    echo -en "Full URL is -- " && echo $fileAddr
    # get archive
    wget -q --show-progress --progress=bar:force 2>&1 $fileAddr
    md5sum $fileName | awk '{print $1}' >> $branch-archive.md5
    tar -xJf $fileName && rm -f *.tar.xz
    cd gcc-linaro-*
    git init && git checkout --orphan $branch
    cp -a ../$branch-archive.md5 .
    git add -A .
    git commit -q -m "Release $branch Linaro Toolchain x86_64 Binaries at $(date +%Y%m%d-%H%M)"
    sleep 3
    git remote add origin https://github.com/rokibhasansagar/linaro-toolchain-latest.git
    git branch --track -f master
    git push -f -q https://$GitOAUTHToken@github.com/rokibhasansagar/linaro-toolchain-latest.git HEAD:$branch
    sleep 2
    cd ..
    rm -rf gcc-linaro-* *.txt *.md5
done
