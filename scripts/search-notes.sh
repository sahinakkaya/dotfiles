#!/bin/bash

tmux popup \
    -w 90% \
    -h 90% \
    -x C \
    -y C \
    -E "/home/sahin/scripts/search-with-ag.sh"
