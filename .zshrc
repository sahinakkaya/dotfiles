# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# secret environment variables goes in /etc/environment
# sudoedit /etc/environment

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
# export TERM="xterm-256color"
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel10k/powerlevel10k"
#ZSH_THEME="robbyrussell"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
  zsh-autosuggestions python pip last-working-dir history sudo command-not-found git extract zsh-syntax-highlighting docker docker-compose zsh-vi-mode z.lua
)

# plugins=(
#   zsh-autosuggestions python pip last-working-dir history dirhistory sudo web-search command-not-found git poetry extract zsh-syntax-highlighting docker docker-compose zsh-vi-mode z.lua
# )
#

# https://stackoverflow.com/questions/28028740/git-tab-completion-in-zsh-throwing-errors
zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
fpath=(~/.zsh $fpath)

ZVM_VI_INSERT_ESCAPE_BINDKEY=kj
ZVM_LAZY_KEYBINDINGS=false

source $ZSH/oh-my-zsh.sh


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=32'
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias rake='noglob bundled_rake'
eval $(thefuck --alias)
unsetopt nomatch
alias weather='curl wttr.in/?0'
alias gdm='gd master'
alias ratslap="~/Downloads/ratslap/ratslap"
alias charmce="/usr/local/bin/charmce"
alias intel="sudo prime-select intel"
alias nvidia="sudo prime-select nvidia"
alias pls="sudo"
alias p="charm ."
alias cat="bat"
alias bd="batdiff"
alias man="batman"
alias cd.="cd .."
alias cd..="cd .."
alias xd="xdg-open &>/dev/null"
alias xd.="xdg-open &>/dev/null ."
alias suod="sudo"
alias sduo="sudo"
alias zz='z -c'      # restrict matches to subdirs of $PWD
alias zi='z -I'      # use fzf to select in multiple matches
alias t="todo.sh"
alias ta="todo.sh add"
alias tl="todo.sh list"
alias td="todo.sh do"
alias tp="todo.sh pri"
alias viz="vim ~/.zshrc"
alias vit="vim ~/.tmux.conf"
alias vip="vim ~/.p10k.zsh"
alias viv="vim ~/.vimrc"
alias viw="vim ~/.which-key.vim"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'


# . /usr/share/autojump/autojump.sh
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/snap/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

eval "$(pyenv virtualenv-init -)"


# If not in tmux session, add battery and time to prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ -n $TMUX ]] || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(battery time)

export VISUAL=vim
export EDITOR="$VISUAL"
export PYTHONBREAKPOINT=ipdb.set_trace
export ZSH_AUTOSUGGEST_USE_ASYNC=true

# https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands
function my_bindings() {
    # easy bindings instead of ctrl + arrow keys
    bindkey '^j' backward-word
    bindkey '^f' forward-word
    bindkey '^g' autosuggest-accept
    bindkey "\e\e" sudo-command-line
}


zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
zvm_after_init_commands+=(my_bindings)
# Always starting with insert mode for each command line
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK

export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
export FZF_DEFAULT_OPTS='--bind change:top'

# export TERM_ITALICS=false

autoload -U compinit; compinit -y

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
