#!/bin/bash

git config --global user.email $GitHubMail
git config --global user.name $GitHubName
git config --global color.ui true

Base_Addr="https://releases.linaro.org/components/toolchain/binaries"
branches="latest-4 latest-5 latest-6 latest-7"

for branch in $branches; do
    echo $branch >> /tmp/branch.txt
    TC_Branch=$(cat '/tmp/branch.txt')
    git checkout '${TC_Branch}'
    curl -s "${Base_Addr}/${TC_Branch}/aarch64-linux-gnu/" | grep "x86_64_aarch64-linux-gnu.tar.xz" | sort | cut -d , -f3 | tail -n 2 | head -n 1 | awk '{print substr($1,2)}' | sed 's/....$//g' >> /tmp/latest-file-name.txt
    File_Name=$(cat '/tmp/latest-file-name.txt')
    FILE_ADDR=${Base_Addr}/${TC_Branch}/$(cat '/tmp/release-file.txt')
    wget -q --show-progress -P /tmp/ ${FILE_ADDR}
    md5sum /tmp/${File_Name} >> /tmp/latest-archive.md5
    if cmp -s "/tmp/latest-archive.md5" "release-archive.md5"; then
        echo "Files are Identical. No need to update"
    else
        cd ..
        rm -rf 'linaro-toolchain-latest/*'
        tar -xJvf /tmp/${File_Name} --directory 'linaro-toolchain-latest/'
        md5sum /tmp/${File_Name} >> 'linaro-toolchain-latest/release-archive.md5'
        cd 'linaro-toolchain-latest/
        git add -A .
        git commit -m "Update Release at $(date +%Y%m%d-%H%M)"
        ##git push origin ${TC_Branch}
        git push -q https://$GitOAUTHToken@github.com/rokibhasansagar/linaro-toolchain-latest.git HEAD:$branch
    fi
done
