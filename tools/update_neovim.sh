#!/usr/bin/bash

rm -rf ./nvim-linux64

wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz

tar -vxf nvim-linux64.tar.gz

rm -rf nvim-linux64.tar.gz
