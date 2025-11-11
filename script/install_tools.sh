# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# zxoide:  https://github.com/ajeetdsouza/zoxide
echo "Install zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# ripgrep: https://github.com/BurntSushi/ripgrep
brew install ripgrep
apt install ripgrep

# fd-find : https://github.com/sharkdp/fd#installation
brew install fd
apt install fd-find

# yazi:  https://yazi-rs.github.io/docs/installation
apt install ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick font-symbols-only-nerd-font

# lazygit: https://github.com/jesseduffield/lazygit#debian-and-ubuntu
sudo apt install lazygit
brew install lazygit

# lsd: https://github.com/lsd-rs/lsd
brew install lsd

# bat: https://github.com/sharkdp/bat
brew install bat
sudo apt install bat

# dust: https://github.com/bootandy/dust
brew install dust

# duf: https://github.com/muesli/duf
brew install duf
