#!/bin/bash
#!/bin/bash
# bootstrap.sh installs things and does some general setup to get us ready to go.

# Change directory to the parent directory of the bootstrap script.
cd "$(dirname "$0")/.."
# Set the DOTFILES_ROOT to the parent directory of the bootstrap script.
DOTFILES_ROOT=$(pwd -P)

# Exit immediately if a simple command exits with a non-zero status, unless
# the command that fails is part of an until or while loop, part of an
# if statement, part of a && or || list, or if the command's return status
# is being inve
set -e

if [ $# -eq 1 ] && [ $1 = "-y" ]
then
    my_git_authorname="Garrett F."
    my_git_email="Gfolks14@gmail.com"
fi


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

      if [ ! -z "$my_git_authorname" ]
      then 
          git_authorname=$my_git_authorname
      else
          user ' - What is your github author name?'
          read -e git_authorname
      fi
      if [ ! -z "$my_git_email" ]
      then 
          git_authoremail=$my_git_email
      else
          user ' - What is your github author email?'
          read -e git_authoremail
      fi

      sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" -e "s/GIT_CREDENTIAL_HELPER/$git_credential/g" ~/.dotfiles/dotfiles/gitconfig.local.symlink.example > ~/.dotfiles/dotfiles/gitconfig.local.symlink

      success 'gitconfig'
  fi
}


link_file () {
    info "Linking files"

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

    success "Files linked"
}

install_dotfiles () {
  info 'Installing dotfiles'

  local overwrite_all=false backup_all=true skip_all=false

  for src in $(find -H "$DOTFILES_ROOT"/.dotfiles/dotfiles -name '*.symlink' -not -path '*.git*')
  do
      dst="$HOME/.$(basename "${src%.*}")"
      link_file "$src" "$dst"
  done

  success "Dotfiles installed"
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

  success 'Vim customization complete'
}

setup_vim_ide() {
    info "Setting up completion engines..."

    COMPLETION_DIR=~/.vim/plugged/youcompleteme/

    if [ -d "$COMPLETION_DIR" ]
    then
        cd $COMPLETION_DIR
        success_file="success.txt"
        if [ ! -f $success_file ]; then
            python3 install.py --clangd-completer
            if [ $? -eq 0 ]; then
                echo "successful install" >> $success_file
                success "Completion engines installed"
            else
                fail "Completion engine installer failed"
            fi
        else
            success "Completion engines already installed"
        fi
    fi

    mkdir -p $HOME/.config/yamllint/
    echo -e "extends: default\nrules:\n  line-length: disable"

}

setup_tools() {
  # Install tools
  info "Installing packages..."
  declare -a packages=("curl" "wget" "vim" "build-essential" "cppcheck" "pylint" "yamllint"
                       "cmake" "unzip" "zsh" "fontconfig" "python3-dev" "x11-xkb-utils"
                       "python3-pip"
                      )

  for package in "${packages[@]}"
  do
      if ! dpkg --status $package > /dev/null 2>&1 ; then
          sudo apt install -y $package
          echo "$package installed"
      else
          success "Already installed $package"
      fi
  done

  success "Packages installed"
}

setup_zsh() {
    info "Customizing ZSH..."

    cd $HOME
    cd .dotfiles

    success_file="font_success.txt"
    if [ ! -f $success_file ]; then
        git clone https://github.com/powerline/fonts.git --depth=1 &> /dev/null
        cd fonts
        ./install.sh &> /dev/null

        if [ $? -eq 0 ]; then
            cd $HOME/.dotfiles
            echo "successful install" >> $success_file
            success "Powerline fonts installed"
        else
            fail "Powerline fonts failed to install"
        fi
        cd $HOME/.dotfiles
        rm -rf fonts
    else
        success "Powerline fonts already installed"
    fi

    success_file="ohmyzsh_success.txt"
    if [ ! -f $success_file ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        if [ $? -eq 0 ]; then
            echo "successful install" >> $success_file
            success "OhMyZsh installed"
        else
            fail "OhMyZsh failed to install"
        fi
    else
        success "OhMyZsh already installed"
    fi
}

setup_aws_cli() {
    info "Installing AWS CLI"
    cd /tmp
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &> /dev/null
    unzip -qq -o awscliv2.zip
    sudo ./aws/install --update
    #rm -rf /tmp/awscliv2.zip /tmp/aws
    pip3 install -U cfn-lint
}

success 'Installation Started'
setup_tools
setup_gitconfig
setup_vim
setup_zsh
install_dotfiles
setup_vim_ide
setup_aws_cli

echo ''
echo '  All installed!'
# Start zsh
sudo chsh -s $(which zsh)
echo "Setup complete - Restart terminal to refresh settings."
