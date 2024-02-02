#!/usr/bin/bash

rm -rf ./nvim-linux64

wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz

tar -vxf nvim-linux64.tar.gz

rm -rf nvim-linux64.tar.gz

if [ "$#" -eq 1 ]; then
	echo 'export PATH=$PATH:'"$(pwd)"/nvim-linux64/bin/ >>~/.exports
	echo "Aleady append PATH env to ~/.exports"
fi
