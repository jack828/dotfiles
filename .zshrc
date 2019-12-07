# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

DEFAULT_USER='jack'

# ZSH Theme
# https://github.com/denysdovhan/spaceship-prompt#oh-my-zsh
ZSH_THEME="spaceship"

# Plugins - can be found in ~/.oh-my-zsh/plugins/*
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git zsh-syntax-highlighting)

# Plugin configs
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

source $ZSH/oh-my-zsh.sh

# History
HIST_STAMPS="dd/mm/yyyy"

# Increase history file limit
# https://github.com/bamos/zsh-history-analysis/blob/master/README.md#increasing-the-history-file-size
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

# For HH - https://github.com/dvorka/hstr
export HISTFILE=~/.zsh_history  # ensure history file visibility

# For android sdk
export ANDROID_HOME=/home/jack/Android/Sdk/
export PATH=${PATH}:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/build-tools
export PATH=${PATH}:/opt/gradle/gradle-4.6/bin

# Allow locally installed npm packages to be in path
export PATH=${PATH}:./node_modules/.bin

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Mongodb
export PATH=~/.mongodb/versions/mongodb-current/bin:$PATH

# NPM global
NPM_PACKAGES="${HOME}/.npm-global"
PATH="$PATH:$NPM_PACKAGES/bin"
unset MANPATH
export MANPATH="$NPM_PACKAGES/SHARE/MAN:$(manpath)"

# For Robo3T
export PATH=/usr/local/robo3t/bin:$PATH

# Pip packages
export PATH=/home/jack/.local/bin:$PATH

# Customising htop, wooo
export HTOPRC=~/.htoprc

# Source own aliases LAST to override zsh's aliases
source ~/.aliases

# Rust stuff
source ~/.cargo/env

# Custom commands
source ~/.commands

# ESP8266 Programming
export PATH=$PATH:$HOME/esp8266/esp-open-sdk/xtensa-lx106-elf/bin
export ESP_OPEN_RTOS_PATH=$HOME/esp8266/esp-open-rtos

# Superior
export EDITOR=nvim

# For git review commands
export REVIEW_BASE=master
