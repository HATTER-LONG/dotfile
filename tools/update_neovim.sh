#!/usr/bin/bash

script_dir=$(cd $(dirname $0) && pwd)

cd $script_dir

rm -rf ./nvim-linux64

wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz

tar -vxf nvim-linux64.tar.gz

rm -rf nvim-linux64.tar.gz

if [ "$#" -eq 1 ]; then
	echo 'export PATH='"$script_dir"/nvim-linux64/bin/':$PATH' >>~/.exports
	echo "Aleady append PATH env to ~/.exports"
fi

cd -
