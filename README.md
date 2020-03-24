
sudo apt-get install ctags cscope git
mv ~/.vim ~/.vim.orig
mv ~/.vimrc ~/.vimrc.orig
git clone https://github.com/oenhan/vim.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle
