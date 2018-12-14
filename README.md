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

## dotfiles
All your customizations and preferences in one place. Add any "dotfile" you want to take with you
to the dotfiles directory with a '.symlink' extension and it will be automatically added when you
run the bootstrap.sh script. Check out the ones already there for examples.

## vim_themes
Take your themes with you wherever you go! If you have a specific vim theme you like to use or
perhaps a custom theme you put together yourself, add it to the vim_themes directory and you'll
be able to use your themes no matter where you are.

## bin
Written a script you wish you had saved so you could use it on another system? Add useful scripts 
to the bin directory and they'll be available on any system you clone your dotfiles to. The bin
directory even gets added to your PATH when the bootstrap.sh script is run. No additional setup needed!

## Note

Some of the files here are taken or modified from other users and as such,
everything here is for use freely under the [MIT License](LICENSE). Thanks to
Zach Holman (@holman), as the original project is based off of his dotfiles project:
https://github.com/holman/dotfiles

