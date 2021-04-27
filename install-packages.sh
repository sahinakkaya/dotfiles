#!/bin/bash

# Installation script, use at your own risk.

# Note: You need to build vim from source. Scroll down for details

NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'


install_package() {
    package=$1
    if dpkg -s $package > /dev/null; then
        echo -e "${CYAN}$package ${GREEN}already installed${NC}"
    else
        sudo apt-get -y install $package 
        if dpkg -s $package > /dev/null; then
            echo "${CYAN}$package ${GREEN}installed${NC}"
        else
            echo "${CYAN}$package ${RED}failed to install!${NC}"
        fi
    fi
}

echo -e "${BLUE}Installing packages...${NC}"

packages=("zsh" "curl" "git" "tmux")
for package in "${packages[@]}"
do
    install_package $package
done
echo -e "${GREEN}Done. ${NC}"


echo -e "${BLUE}Installing oh-my-zsh!${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
echo -e "${GREEN}Done. ${NC}"

function dotfiles {
   /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}


echo -e "${BLUE}Cloning dotfiles...${NC}"
rm -rf $HOME/.cfg
git clone --bare https://github.com/Asocia/dotfiles.git $HOME/.cfg

dotfiles checkout
if [ $? = 0 ]; then
    :
else
    mkdir -p .config-backup
    echo "Backing up pre-existing dot files.";
    dotfiles checkout 2>&1 | egrep "^\s+." | awk {'print $1'} | xargs -I{} mkdir --parents .config-backup/{}
    dotfiles checkout 2>&1 | egrep "^\s+." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    dotfiles checkout
fi;
dotfiles config status.showUntrackedFiles no
echo -e "${GREEN}Done. ${NC}"


echo -e "${BLUE}Installing custom zsh plugins...${NC}"
git clone --quiet https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --quiet https://github.com/jeffreytse/zsh-vi-mode ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-vi-mode

git clone --quiet https://github.com/skywind3000/z.lua ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/z.lua
git clone --quiet --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

sudo pip3 --quiet install thefuck

echo -e "${GREEN}Done. ${NC}"


echo -e "${BLUE}Changing default shell to zsh...${NC}"
chsh -s $(which zsh)
echo -e "${GREEN}Done. ${NC}"

# Build vim first
# https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source

# Create required directories
mkdir -p ~/.vim/tmp
mkdir -p ~/.vim/undo
mkdir -p ~/.vim/backup

echo -e "${BLUE}Installing vim plugins...${NC}"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

vim +PluginInstall +qall
vim +PlugInstall +qall
echo -e "${GREEN}Done. ${NC}"
clear;

echo -e "${BLUE}Installing YCM. This might take a few minutes${NC}"
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all > /dev/null;
cd
echo -e "${GREEN}Done. ${NC}"

echo -e "${BLUE}Installing tmux plugins...${NC}"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
echo -e "${GREEN}Done. ${NC}"

echo -e "${GREEN}Installation finished. Log in again to see the effect.${NC}"
