#!/bin/bash -x
# Opendax bootstrap script
# run as root@system

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

add_user() {
  useradd -g users -s `which bash` -m app
  echo "ALL ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  su - app
  sudo usermod -aG sudo $USER
}

install_core() {
  sudo bash <<EOS
apt-get update
apt-get install -y git tree htop tmux gnupg2 dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
EOS
}

# NVM installation
install_nvm() {
  sudo -u app bash <<EOS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
EOS
  source ~/.bashrc
  nvm install v10.*
  nvm alias v10.*
  npm install -g pm2 gtop
}

install_rvm() {
  sudo -u app bash <<EOS
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
#rvm get stable --auto-dotfiles
EOS
  source ~/.bashrc
  rvm install "ruby-2.6.3"
  rvm alias create default "ruby-2.6.3"
  source ~/.bashrc && source ~/.profile
  gem install bundler
}

# Docker Config
log_rotation() {
  sudo bash <<EOS
mkdir -p /etc/docker
echo '
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  }
}' > /etc/docker/daemon.json
EOS
}

# Docker installation
install_docker() {
  sudo apt-get remove docker docker-engine docker.io containerd runc
  curl -fsSL https://get.docker.com/ | bash
  sudo bash <<EOS
usermod -a -G docker $USER
curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOS
}

install_gcloud() {
  sudo bash <<EOS
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk -y
EOS
}

activate_gcloud() {
  sudo -u app bash <<EOS
gcloud auth configure-docker --quiet
EOS
}

install_twilio() {
  sudo apt-get install libsecret-1-dev
  npm install twilio-cli -g
}



# Function Calls (Sequince Matters!)
add_user
install_core
install_nvm
install_rvm
log_rotation
install_docker
install_gcloud
activate_gcloud

