# Always start a tmux session when opening up terminal
if type tmux &> /dev/null; then
    session_name=${YAKUAKE:-Konsole}
    #if not inside a tmux session, start a new session
    if [[ $HOST == "ubuntu" && -z "$TMUX" ]]; then
        (tmux -2 new-session -A -s $session_name || false)
        # || false makes Konsole happy while quitting. It doesn't ask for
        # confirmation. Since we are in tmux, it doesn't matter if we really
        # wanted to quit or not
    fi
fi
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

POWERLEVEL9K_MODE='nerdfont-complete'
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="mm/dd/yyyy"


# plugins=()
plugins=(
  zsh-autosuggestions python pip last-working-dir history sudo command-not-found git extract zsh-syntax-highlighting docker docker-compose zsh-vi-mode z.lua
)
plugins+=(zsh-prompt-benchmark)


# https://stackoverflow.com/questions/28028740/git-tab-completion-in-zsh-throwing-errors
zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
fpath=(~/.zsh $fpath)

ZVM_VI_INSERT_ESCAPE_BINDKEY=kj
ZVM_LAZY_KEYBINDINGS=false

source $ZSH/oh-my-zsh.sh


ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=32'
# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

export LANG=en_US.UTF-8


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


export PATH="/snap/bin:$PATH"


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

autoload -U compinit; compinit -y
