已废弃请使用[这个配置](https://github.com/GeekerFeng/vim)

I use python3
```shell
sudo apt install cscope git global python3-pygments python3-flake8 python3 python3-dev cmake
sudo add-apt-repository ppa:extk/chyla.org-repository-for-ubuntu-18.04 #if system is ubuntu-18.04
sudo apt update
sudo apt install universal-ctags
mv ~/.vim ~/.vim.orig
mv ~/.vimrc ~/.vimrc.orig
git clone https://github.com/hkurj/c-c-vimIDE.git ~/.vim
ln -s ~/.vim/vimrc ~/.vimrc
sudo ln -s ~/.vim/gtags.conf /etc/
sudo apt install cppcheck shellcheck golint pylint
```
