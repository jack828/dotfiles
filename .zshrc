# mmmm, secrets...
  [ -f ~/.secrets ] && source ~/.secrets

# ZSH
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

# Android SDK
  export ANDROID_HOME=/home/jack/Android/Sdk/
  export PATH=${PATH}:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/build-tools
  export PATH=${PATH}:/opt/gradle/gradle-4.6/bin

# NodeJS
  # Allow locally installed npm packages to be in path
  export PATH=${PATH}:./node_modules/.bin

  # NPM global
  export NPM_PACKAGES="${HOME}/.npm-global"
  export PATH="$PATH:$NPM_PACKAGES/bin"
  unset MANPATH
  export MANPATH="$NPM_PACKAGES/SHARE/MAN:$(manpath)"

# ESP32
export PATH="/home/jack/esp/esp-idf/components/:${PATH}"

# ESP8266 Programming
  export PATH=$PATH:$HOME/esp8266/esp-open-sdk/xtensa-lx106-elf/bin
  export ESP_OPEN_RTOS_PATH=$HOME/esp8266/esp-open-rtos

# Applications
  # Mongodb
    export PATH=~/.mongodb/versions/mongodb-current/bin:$PATH

  # For Robo3T
    export PATH=/usr/local/robo3t/bin:$PATH

  # Pip packages
    export PATH=/home/jack/.local/bin:$PATH

  # Customising htop, wooo
    export HTOPRC=~/.htoprc

  # Rust stuff
    source ~/.cargo/env

  # LaTeX
    export PATH=/usr/local/texlive/2019/bin/x86_64-linux:$PATH

  # FZF
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Superior
  export EDITOR=nvim

# For git review commands
# see .gitconfig
  export REVIEW_BASE=master

# Custom commands
  source ~/.commands

# Source own aliases LAST to override zsh's aliases
  source ~/.aliases
