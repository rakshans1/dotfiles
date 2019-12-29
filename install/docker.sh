
if ! [ -x "$(command -v docker)" ]; then
    echo "Installing Docker"
    wget -qO- https://get.docker.com/ | sh
    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo service docker restart
fi
if ! [ -x "$(command -v docker-compose)" ]; then
    echo "Installing Docker"
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi
