# Path to your oh-my-zsh installation.
export ZSH=/Users/jackburgess/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE='awesome-patched'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_DIR_BACKGROUND='white'

DEFAULT_USER='jackburgess'

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# Plugins - can be found in ~/.oh-my-zsh/plugins/*
# k - git clone https://github.com/supercrabtree/k $HOME/.oh-my-zsh/custom/plugins/k
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
plugins=(git k zsh-syntax-highlighting)

# Plugin configs
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)

# User configuration
export PATH="$HOME/npm-global/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# For HH - https://github.com/dvorka/hstr
export HISTFILE=~/.zsh_history  # ensure history file visibility
export HH_CONFIG=hicolor        # get more colors
bindkey -s "\C-r" "\eqhh\n"     # bind hh to Ctrl-r (for Vi mode check doc)

# For android sdk
export ANDROID_HOME=~/android-sdk-macosx/
export PATH=${PATH}:~/android-sdk-macosx/platform-tools:~/android-sdk-macosx/tools

# FZF 
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Mongodb
export PATH=~/.mongodb/versions/mongodb-current/bin:$PATH

# Source own aliases LAST to override zsh's aliases
source ~/.aliases
