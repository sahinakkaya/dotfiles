
d="$HOME/scripts/colorscripts"
bash "$d/`ls $d | shuf -n 1`"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#


# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi


fpath=("${ZDOTDIR:-$HOME}/.zsh" $fpath)

# Customize to your needs...
source "${ZDOTDIR:-$HOME}/.aliases"

ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_MANUAL_REBIND=true


# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/last-working-dir/last-working-dir.plugin.zsh
zinit snippet OMZ::plugins/dirhistory/dirhistory.plugin.zsh
zinit light skywind3000/z.lua

# ZVM
function zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
  ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
  ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
  ZVM_LAZY_KEYBINDINGS=true
  ZVM_VI_INSERT_ESCAPE_BINDKEY=kj
}

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    bindkey '^b' backward-word
    bindkey '^f' forward-word
    bindkey '^g' autosuggest-accept
    # allow ctrl-r and ctrl-s to search the history
    # bindkey '^r' history-incremental-search-backward
    # bindkey '^s' history-incremental-search-forward
    bindkey '^h' backward-kill-word
    bindkey '^[[M' kill-word
    bindkey -s '^@' ""
    bindkey -s '' "fg\n"


    # allow ctrl-a and ctrl-e to move to beginning/end of line
    bindkey '^a' beginning-of-line
    bindkey '^e' end-of-line


    # allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
    # bindkey '^h' backward-delete-char
    bindkey '^w' backward-kill-word


    bindkey '^x' fzf-cd-widget
    bindkey "\e[1;3D" dirhistory_zle_dirhistory_back
    bindkey "\e[1;3C" dirhistory_zle_dirhistory_future
    bindkey "\e[1;3A" dirhistory_zle_dirhistory_up
    bindkey "\e[1;3B" dirhistory_zle_dirhistory_down
}

doit ()
{
  # this function is created for forcing the deletion of the file or directory.
  # 
  # ❯ rm somedir
  # rm: cannot remove 'somedir': Is a directory
  # ❯ rmdir somedir/
  # rmdir: failed to remove 'somedir/': Directory not empty
  # ❯ rm -rf somedir/
  # rm: cannot remove 'somedir/': Permission denied
  # 
  # Just remove the f**king directory!!


  lastCommand=$(history | tail -n 1 | cut -d' ' -f3-)
  firstWord=$(echo $lastCommand | cut -d' ' -f1)
  RED="\033[1;31m"
  GREEN="\033[1;32m"
  NOCOLOR="\033[0m"

  lastWord=$(echo $lastCommand | awk '{print $NF}')
  case "$firstWord" in
    "rm"|"rmdir") 
      echo -en "Execute ${RED}\"sudo rm -rf $lastWord\"${NOCOLOR}?"
      read -k "? " ans
      echo 
      if [ "$ans" = "y" ]; then
        sudo rm -rf $lastWord
      fi
    ;;
    "cd") 
      mkdir $lastWord && cd $lastWord
    ;;
    *) echo "Don't know what to do with \"$lastCommand\"." 
    ;;
  esac
}

