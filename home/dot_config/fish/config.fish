set -gx EDITOR vim
set -gx VISUAL vim
if not set -q XDG_CONFIG_HOME
    set -gx XDG_CONFIG_HOME "$HOME/.config"
end
fish_add_path --path "$HOME/.local/bin"

alias co cpyout
alias so shrout
alias cf cpyfile
alias sf shrfile
alias s "git status ."
alias d "git diff ."
alias ltr "ls -ltr"
alias .c "cd ~/.config"
alias .b "cd ~/.local/bin"
alias .s "cd ~/scripts"
alias .g "cd ~/GitRepositories"
alias .d "cd ~/Downloads"

if status is-interactive
    set -g fish_greeting
end
