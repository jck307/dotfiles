#!/bin/python

import os

input("""Make sure you are in a directory such as ~/dotfiles
Proceed by pressing enter, cancel by pressing Ctrl-C """)

def cmd(command):
    print(command)
    os.system(command)

simple = (
    (".bashrc", "~"),
    (".bash_login", "~"),
    (".profile", "~"),
    (".zshrc", "~"),
    (".inputrc", "~"),
    ("colors.env", "~"),
    ("commands.sh", "~"),
)

overwrite = [
    ("PATH", "~"),
    ("Bar", "~"),
]

overwrite_subdirs = (
    ".config",
)

for name in overwrite_subdirs:
    for subdir in os.listdir(name):
        # TODO check if directory?
        overwrite.append((name + "/" + subdir, "~/" + name))

for src, dest in simple:
    cmd(f"ln -f {src} {dest}")

for src, dest in overwrite:
    cmd(f"rm -rf ~/{src}")
    cmd(f"cp -rl {src} {dest}")

