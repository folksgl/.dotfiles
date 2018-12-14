# Garrett Folks' <img src="dotfiles-logo.png" alt="dotfiles logo" width="150">

This is a collection of dotfiles and scripts I use for customizing my terminal
environment, where I spend most of my time when working. The files here
are currently used for customizing the following:

- Bash
- Vim
- Tmux
- Git
- bin/
- Zsh

The repository should be cloned into your home directory (copy/pasting the installation
commands will do this for you). Dotfiles you wish to keep track of should be located in 
the .dotfiles/dotfiles directory. They will need to have a ".symlink" extention that the 
bootstrap.sh script will use to symlink dotfiles you wish to track in your home directory.

The bootstrap.sh script will do all of the setup, so that installation on a new 
machine is as streamlined as possible. It is set up to be modular, so adding a 
new dotfile to your collection will only involve adding the .symlink file to the
repository. If additional setup needs to be done, an additional function call in
bootstrap.sh will need to be added.

## Installation
```sh
git clone https://github.com/folksgl/.dotfiles.git ~/
~/.dotfiles/bootstrap.sh
```

## Note

Some of the files here are taken or modified from other users and as such,
everything here is for use freely under the [MIT License](LICENSE)

