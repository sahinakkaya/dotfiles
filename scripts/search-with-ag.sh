#!/bin/bash
result=$(ag --nobreak --nonumbers --noheading . ~/GitRepositories/til/ | fzf --ansi --preview='file=$(echo {} | cut -d':' -f1); bat --style=numbers,changes --wrap never --color always $file')


# do not use the following because it does not show anything if it can't find exact match inside the file. kills the point of fuzzy finding
# result=$(ag --nobreak --nonumbers --noheading . /home/sahin/PythonProjects/til/ | fzf --ansi --preview='file=$(echo {} | cut -d':' -f1); batgrep --color --context 100 {q} $file')

if [ ! "$result" ];then
  exit 0
fi
/home/sahin/.local/bin/lvim $(echo $result | cut -d':' -f1)
