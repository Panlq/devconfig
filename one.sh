#!/usr/bin bash
set -e

function change_apt_source() {
    ## 备份原始源
    cp /etc/apt/sources.list /etc/apt/sourses.list.bak

    # 替换国源
    # https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/  18.04
    cat >>/etc/apt/sources.list <<-'EOF'
    # 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse
    deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse

    # 预发布软件源，不建议启用
    # deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
    # deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-proposed main restricted universe multiverse
EOF

    # 更新源
    sudo apt-get -y update

    # 安装源
    sudo apt-get -y upgrade

}

function set_github_proxy() {
    # github ip
    cat >>/etc/hosts <<-'EOF' 
        # update: 20220222
        # Github Hosts
        # domain: github.com
        140.82.113.4 github.com
        140.82.114.9 nodeload.github.com
        140.82.112.5 api.github.com
        140.82.112.10 codeload.github.com
        185.199.108.133 raw.github.com
        185.199.108.153 training.github.com
        185.199.108.153 assets-cdn.github.com
        185.199.108.153 documentcloud.github.com
        140.82.114.17 help.github.com

        # domain: githubstatus.com
        185.199.108.153 githubstatus.com

        # domain: fastly.net
        199.232.69.194 github.global.ssl.fastly.net

        # domain: githubusercontent.com
        185.199.108.133 raw.githubusercontent.com
        199.232.4.133 raw.githubusercontent.com
        185.199.108.154 pkg-containers.githubusercontent.com
        185.199.108.133 cloud.githubusercontent.com
        185.199.108.133 gist.githubusercontent.com
        185.199.108.133 marketplace-screenshots.githubusercontent.com
        185.199.108.133 repository-images.githubusercontent.com
        185.199.108.133 user-images.githubusercontent.com
        185.199.108.133 desktop.githubusercontent.com
        185.199.108.133 avatars.githubusercontent.com
        185.199.108.133 avatars0.githubusercontent.com
        185.199.108.133 avatars1.githubusercontent.com
        185.199.108.133 avatars2.githubusercontent.com
        185.199.108.133 avatars3.githubusercontent.com
        185.199.108.133 avatars4.githubusercontent.com
        185.199.108.133 avatars5.githubusercontent.com
        185.199.108.133 avatars6.githubusercontent.com
        185.199.108.133 avatars7.githubusercontent.com
        185.199.108.133 avatars8.githubusercontent.com
        # End of the section
EOF

}

function install_zsh() {
    # 安装 zsh
    echo "安装 zsh"
    sudo apt-get -y install zsh

    # 修改默认的 Shell 为 zsh
    echo "修改默认的 Shell 为 zsh"
    chsh -s /bin/zsh

    # oh-my-zsh
    echo "安装 oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # 配置zsh
    # p10k
    git clone https://github.com/bhilburn/powerlevel9k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel9k
    # 命令行提示
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # 语法高亮
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    # autojump 插件，自动跳转目录
    git clone git://github.com/wting/autojump.git
    cd autojump
    ./install.py

    # 配合.zshrc文件使用
}


function install_dev_kit() {
    apt-get install -y
    # 安装python
    apt-get install -y python3 python3-dev python3-pip

    # 安装go多版本管理工具
    curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash

    # 下载libreadline相关支持
    apt-get -y install libreadline5 libreadline-gplv2-dev

    # 安装lua
    curl -R -O http://www.lua.org/ftp/lua-5.4.4.tar.gz
    tar zxf lua-5.4.4.tar.gz
    cd lua-5.4.4
    make all test

    make install

    # echo
    lua -v
}


# neovim安装

function install_neovim() {
        # 安装依赖
    apt-get update -y
    apt-get install -y git curl lua5.3 nodejs || ! echo

    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage

    ./nvim.appimage --appimage-extract
    ./squashfs-root/AppRun --version

    # Optional: exposing nvim globally.
    mv squashfs-root /
    ln -s /squashfs-root/AppRun /usr/bin/nvim
    nvim --version

    # 配置插件
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

}



main() {
    change_apt_source
    set_github_proxy
    install_zsh
    install_dev_kit
    install_neovim
}

main