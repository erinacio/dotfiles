#!/bin/sh
# Update bundled grml's zsh setup
wget http://git.grml.org/f/grml-etc-core/etc/zsh/zshrc -O zsh-custom/core/01-init.zsh \
    && sed -i -E 's|^\s+compinit|# compinit|' zsh-custom/core/01-init.zsh
