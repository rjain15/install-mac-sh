#!/bin/bash


install_brew() { 
 /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 brew update                           # Fetch latest version of homebrew and formula.
 brew install cask
 brew cleanup
}

add_taps() {
 echo "Add Taps"
 brew tap weaveworks/tap
 brew tap
  
}

add_vscode() {
 brew update                           # Fetch latest version of homebrew and formula.
 brew search visual-studio-code        # Searches all known Casks for a partial or exact match.
 brew install --cask visual-studio-code  # Install the given cask.
 brew cleanup
}

config_zsh() {
  chsh -s /bin/zsh
  brew install romkatv/powerlevel10k/powerlevel10k
  echo 'source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

  # Install zsh as default shell for code https://medium.com/fbdevclagos/updating-visual-studio-code-default-terminal-shell-from-bash-to-zsh-711c40d6f8dc
  echo " Add to ~/Library/Application\ Support/Code/User/settings.json the following"
  echo '  "terminal.integrated.shell.osx": "/bin/zsh" '
  p10k configure
}

install_formulaes() {
 echo "Upgrade Formulaes"

#  for f in $(cat brew.txt); 
#  do 
#     echo $f; 
#     brew install $f
#  done
 brew install $(cat brew.txt)
}

upgrade_formulaes() {
 echo "Upgrade Formulaes"
 brew upgrade $(cat brew.txt)
}

setup_git_keys() {
  ssh-keygen -t rsa -b 4096 -C "rjain15@gmail.com" -f ~/.ssh/rjain_git
  cat ~/.ssh/rjain_git.pub | pbcopy
  echo "Paste this key in Git Account"  
  read -p "Press enter to continue"
  printf "#Personal GitHub account\n Host github.com\n  HostName github.com\n  User git\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/rjain_git" >> ~/.ssh/config
}

setup_git_cli() { 
  echo "Best Cli from Github: https://github.com/cli/cli"
  brew install github/gh/gh

}

setup_nvm () {

  brew install nvm yarn 
  if [ -f "~/.nvm" ]; then
    mkdir ~/.nvm
  fi
  echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc  
  echo '[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm' >>  ~/.zshrc  
  echo '[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.zshrc  
  source ~/.zshrc

  nvm install v13.12.0 
  nvm use default

}

setup_aws_cli() {
  curl "https://d1vvhvl2y92vvt.cloudfront.net/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
  sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
  ln -s /usr/local/aws-cli/aws2 /usr/local/bin/aws  
}

uninstall_aws_cli() {
  sudo rm /usr/local/bin/aws
  sudo rm /usr/local/bin/aws2_completer
  sudo rm -rf /usr/local/aws-cli
  sudo rm /usr/local/bin/aws2
  sudo rm /usr/local/bin/aws-iam-authenticator
  sudo rm -rf /usr/local/aws-cli

}

setup_azure_cli() {
  echo "Azure cli"
  brew update && brew install azure-cli
  az login
}

install_gcp_cli() {
  \curl https://sdk.cloud.google.com | bash 

  source ~/.zshrc
}

setup_gcp_cli() {
  gcloud init
  gcloud config list
  gcloud info
  gcloud config set accessibility/screen_reader true

}



setup_k8s() {
 gcloud components install kubectl beta
}



setup_aporeto_cli() {
  brew install jq
  brew tap mike-engel/jwt-cli
  brew install jwt-cli

  sudo curl -o /usr/local/bin/apoctl \
    https://download.aporeto.com/releases/release-3.12.13/apoctl/darwin/apoctl && \
  sudo chmod 755 /usr/local/bin/apoctl
  eval $(apoctl auth google -e) 
  apoctl auth verify  
  

}

setup_twistlock_gcloud() {
  ssh-keygen  -t rsa -f ~/.ssh/gcloud_rsa
  gcloud compute os-login ssh-keys add --key-file ~/.ssh/gcloud_rsa.pub
  gcloud compute --project "cto-demos-245420" ssh --zone "us-central1-a" central-demo-build --ssh-key-file=~/.ssh/gcloud_rsa
  gcloud compute --project "cto-demos-245420" scp /Users/rajain/code/twistlock.lic rajain_paloaltonetworks_com@central-demo-build:/home/rajain_paloaltonetworks_com/.  --ssh-key-file=~/.ssh/gcloud_rsa
}


setup_twist_cli() {
  echo "Configure Twistlock cli, make sure you have downloaded the twistcli from the console"

}

setup_rvm() {
  \curl -sSL https://get.rvm.io | bash -s stable
  source /Users/rajain/.rvm/scripts/rvm 
  rvm install 2.6 
}

setup_pks() {
  gem install cf-uaac

}

setup_anaconda() {
  brew install --cask anaconda
  echo 'export PATH="/usr/local/anaconda3/bin:$PATH"' >> ~/.zshrc
  brew install spatialindex
  conda install geopandas, descartes, rtree 
  pip install folium
  pip install pysal
  

}
main() {
   echo "Installing all mac utils"
  #  install_brew
    add_taps
    install_formulaes
    setup_nvm
    add_vscode
  config_zsh
    setup_git_keys
    setup_aws_cli
  #  uninstall_aws_cli
   install_gcp_cli
   setup_gcp_cli
   setup_k8s
   setup_anaconda
}

main

