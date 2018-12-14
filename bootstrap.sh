#!/bin/bash
# bootstrap.sh installs things and does some general setup to get us ready to go.

# Change directory to the parent directory of the bootstrap script.
cd "$(dirname "$0")/.."
# Set the DOTFILES_ROOT to the parent directory of the bootstrap script.
DOTFILES_ROOT=$(pwd -P)

# Exit immediately if a simple command exits with a non-zero status, unless
# the command that fails is part of an until or while loop, part of an
# if statement, part of a && or || list, or if the command's return status
# is being inverted using !
set -e

echo ''

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
  printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

setup_gitconfig () {
  if ! [ -f ~/.dotfiles/gitconfig.local.symlink ]
  then
    info 'setup gitconfig'

    git_credential='cache'
    if [ "$(uname -s)" == "Darwin" ]
    then
      git_credential='osxkeychain'
    fi

    user ' - What is your github author name?'
    read -e git_authorname
    user ' - What is your github author email?'
    read -e git_authoremail

    sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ~/.dotfiles/dotfiles/gitconfig.local.symlink.example > ~/.dotfiles/dotfiles/gitconfig.local.symlink

    success 'gitconfig'
  fi
}


link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles () {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$DOTFILES_ROOT"/.dotfiles/dotfiles -name '*.symlink' -not -path '*.git*')
  do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
  sudo apt install x11-xkb-utils -y &> /dev/null
}

setup_vim () {
  info 'Customizing Vim'

  COLORS_DIR=~/.vim/colors/
  THEME=~/.dotfiles/vim_themes/spring-night.vim

  if [ ! -d "$COLORS_DIR" ]
  then
      mkdir -p $COLORS_DIR
  fi
  cp $THEME $COLORS_DIR

  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &> /dev/null
  
  vim +PlugInstall +PlugUpdate +qall

  success 'Vim Customization'
}

setup_tools() {
  # Curl
  if [ -z $(command -v curl) ]; then
    sudo apt-get install curl -y &> /dev/null
    success 'Curl Installed'
  fi

  # Vim
  if [ -z $(command -v vim) ]; then
    sudo apt-get install vim -y &> /dev/null
    success 'Vim Installed'
  fi

  # Wget
  if [ -z $(command -v wget) ]; then
    sudo apt-get install wget -y &> /dev/null
    success 'wget Installed'
  fi

}

setup_zsh() {

    sudo apt-get install zsh -y &> /dev/null 
    success 'Installed zsh'

    sudo apt-get install fontconfig -y &> /dev/null
    cd $HOME
    git clone https://github.com/powerline/fonts.git --depth=1 &> /dev/null
    cd fonts
    ./install.sh &> /dev/null
    cd ..
    rm -rf fonts
    success 'Installed patched fonts'

    ~/.dotfiles/install.sh
    sed -i 's/prompt_segment blue/prompt_segment red/g' ~/.oh-my-zsh/themes/agnoster.zsh-theme
    success 'Installed ohmyzsh'
}

success 'Installation Started'
setup_tools
setup_gitconfig
install_dotfiles
setup_vim
setup_zsh

echo ''
echo '  All installed!'
