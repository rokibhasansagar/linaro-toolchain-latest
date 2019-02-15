#!/bin/bash

git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true

baseAddr="https://releases.linaro.org/components/toolchain/binaries"
branches="latest-4 latest-5 latest-6 latest-7"

mkdir ../temp || echo -e "../temp folder creation error"

for branch in $branches; do
    echo -en "Current branch is --" && echo $branch
    echo $branch >> ../temp/branch.txt
    tcBranch=$(cat '../temp/branch.txt')
    echo -en "ToolChain branch is --" && echo $tcBranch
    git checkout "$tcBranch"
    echo -e "Getting new file name from release server"
    curl -s "$baseAddr/$tcBranch/aarch64-linux-gnu/" | grep "x86_64_aarch64-linux-gnu.tar.xz" | sort | cut -d , -f3 | tail -n 2 | head -n 1 | awk '{print substr($1,2)}' | sed 's/....$//g' >> ../temp/latest-file-name.txt
    fileName=$(cat '../temp/latest-file-name.txt')
    echo -en "New filename is -- " && echo $fileName
    fileAddr=$baseAddr/$tcBranch/$(cat '../temp/release-file.txt')
    echo -en "Full URL is -- " && echo $fileAddr
    wget -q --show-progress -P ../temp/ $fileAddr
    ls -la ../temp/ || echo "File download error"
    md5sum ../temp/$fileName >> ../temp/latest-archive.md5
    if cmp -s "../temp/latest-archive.md5" "release-archive.md5"; then
        echo "Files are Identical. No need to update"
    else
        cd ..
        rm -rf linaro-toolchain-latest/*
        tar -xJvf ../temp/$fileName --directory linaro-toolchain-latest/
        md5sum ../temp/$fileName >> linaro-toolchain-latest/release-archive.md5
        cd linaro-toolchain-latest/
        git add -A .
        git commit -m "Update Release at $(date +%Y%m%d-%H%M)"
        ##git push origin ${TC_Branch}
        git push -q https://$GitOAUTHToken@github.com/rokibhasansagar/linaro-toolchain-latest.git HEAD:$branch
    fi
done
