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
-    # Commands to run in interactive sessions can go here
-    bind \cg accept-autosuggestion
-    bind \cf forward-word
-    bind \cb backward-word
-    alias icat="kitten icat"
-    alias crontab='crontab -i'
end
