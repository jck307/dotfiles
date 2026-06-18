#!/bin/sh

set -a # automatically export all variables

source ~/colors.env
# source ~/.bashrc

# PATH settings:

# add to PATH: ~/PATH, ., ~/.cargo/bin
PATH=~/PATH:$PATH:.:~/.cargo/bin
PYTHONPATH=/home/jack/Programmering/PYTHONPATH

EDITOR=nvim
VISUAL=$EDITOR
SUDO_EDITOR=$EDITOR

set +a
