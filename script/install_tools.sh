os_kernel=$(uname -s)
# homebrew
echo ">>>>>>>>>> Install homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ "$os_kernel" = "Darwin" ]; then
  echo " 当前系统是 macOS"
else
  echo " 当前系统是 Linux"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>~/.zshrc
fi
source ~/.zshrc

# zxoide:  https://github.com/ajeetdsouza/zoxide
#
echo ">>>>>>>>>> Install zoxide"
brew install zoxide

# ripgrep: https://github.com/BurntSushi/ripgrep
echo ">>>>>>>>>> Install ripgrep"
brew install ripgrep

# fd-find : https://github.com/sharkdp/fd#installation
echo ">>>>>>>>>> Install fd"
brew install fd

# yazi:  https://yazi-rs.github.io/docs/installation
echo ">>>>>>>>>> Install yazi"
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font

# lazygit: https://github.com/jesseduffield/lazygit#debian-and-ubuntu
echo ">>>>>>>>>> Install lazygit"
brew install lazygit

# lsd: https://github.com/lsd-rs/lsd
#
echo ">>>>>>>>>> Install lsd"
brew install lsd

# bat: https://github.com/sharkdp/bat
echo ">>>>>>>>>> Install bat"
brew install bat

# dust: https://github.com/bootandy/dust
echo ">>>>>>>>>> Install dust"
brew install dust

# duf: https://github.com/muesli/duf
echo ">>>>>>>>>> Install duf"
brew install duf

# lazydocker: https://github.com/jesseduffield/lazydocker
echo ">>>>>>>>>> Install lazydocker"
brew install jesseduffield/lazydocker/lazydocker

# lazyssh: https://github.com/Adembc/lazyssh
# brew install Adembc/homebrew-tap/lazyssh

# others
echo ">>>>>>>>>> Install tmux"
brew install tmux

echo ">>>>>>>>>> Install other packages"
brew install neovim btop trash-cli

# starship
echo ">>>>>>>>>> Install starship"
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init zsh)"' >>~/.zshrc

echo "Installing Finish"
