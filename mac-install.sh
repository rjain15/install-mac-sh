#!/bin/bash


install_brew() { 
 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 brew update                           # Fetch latest version of homebrew and formula.
 brew tap caskroom/cask                # Tap the Caskroom/Cask repository from Github using HTTPS.
 brew cleanup
}

add_taps() {
 echo "Add Taps"
 brew tap weaveworks/tap
 brew tap
  
}

add_vscode() {

 brew update                           # Fetch latest version of homebrew and formula.
 brew tap homebrew/cask-cask                # Tap the Caskroom/Cask repository from Github using HTTPS.
 brew search visual-studio-code        # Searches all known Casks for a partial or exact match.
 brew cask info visual-studio-code     # Displays information about the given Cask
 brew cask install visual-studio-code  # Install the given cask.
 brew cleanup


}

config_zsh() {
  chsh -s /bin/zsh
  # Install Powerlevel9k https://github.com/Powerlevel9k/powerlevel9k/wiki/Install-Instructions
  brew tap sambadevi/powerlevel9k
  brew install powerlevel9k
  echo "source /usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme" >> ~/.zshrc
  # Install nerd-font https://github.com/ryanoasis/nerd-fonts
  brew tap homebrew/cask-fonts
  brew cask install font-hack-nerd-font  
  echo "POWERLEVEL9K_MODE='nerdfont-complete'" >> ~/.zshrc
  # Install zsh as default shell for code https://medium.com/fbdevclagos/updating-visual-studio-code-default-terminal-shell-from-bash-to-zsh-711c40d6f8dc
  echo " Add to ~/Library/Application\ Support/Code/User/settings.json the following"
  echo '  "terminal.integrated.shell.osx": "/bin/zsh" '

}

install_formulaes() {
 echo "Install Formulaes"
 
 for f in $(cat brew.txt); 
 do 
    echo $f; 
    brew install $f
 done


}

setup_git_keys() {
  # ssh-keygen -t rsa -f ~/.ssh/rjain_git
  cat ~/.ssh/rjain_git | pbcopy
  echo "Paste this key in Git Account"  
  read -p "Press enter to continue"
  printf "#Personal GitHub account\n Host github.com\n  HostName github.com\n  User git\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/rjain_rsa" >> ~/.ssh/config
}

setup_nvm () {

  mkdir ~/.nvm

  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bash_profile
  echo '[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm' >>  ~/.bash_profile
  echo '[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.bash_profile


}

main() {
   echo "Installing all mac utils"
   # install_brew
   # add_taps
   # install_formulaes
   # setup_nvm
   # add_vscode
   # change_zsh
   setup_git_keys
}

main

