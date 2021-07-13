# Always start a tmux session when opening up terminal
if type tmux &> /dev/null; then
    session_name=${TERMINAL_NAME:-Terminal}
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
# ENABLE_CORRECTION="true"

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
  gitignore alias-finder zsh-autosuggestions pip last-working-dir dirhistory history thefuck command-not-found git extract zsh-syntax-highlighting docker docker-compose zsh-vi-mode z.lua pyenv-lazy
)
# plugins+=(zsh-prompt-benchmark)


ZVM_LAZY_KEYBINDINGS=false
ZVM_VI_INSERT_ESCAPE_BINDKEY=kj


source $ZSH/oh-my-zsh.sh
source ~/.p10k.zsh

# https://stackoverflow.com/questions/28028740/git-tab-completion-in-zsh-throwing-errors
zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
fpath=(~/.zsh $fpath)

unsetopt nomatch

export LANG=en_US.UTF-8
export VISUAL=nvim
export EDITOR="$VISUAL"
export PYTHONBREAKPOINT=ipdb.set_trace
export ZSH_AUTOSUGGEST_USE_ASYNC=true
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=32'
export ZSH_AUTOSUGGEST_MANUAL_REBIND=true
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -l -g ""'
export FZF_DEFAULT_OPTS='--bind change:top'
# export TERM_ITALICS=false
export PATH="$HOME/.poetry/bin:$PATH"
export PATH=$PATH:$HOME/scripts


# . /usr/share/autojump/autojump.sh
export PATH="/snap/bin:$PATH"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1


# If not in tmux session, add battery and time to prompt
[[ -n $TMUX ]] || POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(battery time)


# https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands
function my_bindings() {
    # easy bindings instead of ctrl + arrow keys
    bindkey '^b' backward-word
    bindkey '^f' forward-word
    bindkey '^g' autosuggest-accept
    bindkey "\e\e" fuck-command-line
    bindkey "\e[1;3D" dirhistory_zle_dirhistory_back
    bindkey "\e[1;3C" dirhistory_zle_dirhistory_future
    bindkey "\e[1;3A" dirhistory_zle_dirhistory_up
    bindkey "\e[1;3B" dirhistory_zle_dirhistory_down
}


zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')
zvm_after_init_commands+=(my_bindings)
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT # Always starting with insert mode for each command line
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLOCK

autoload -U compinit; compinit -y
