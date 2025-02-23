#!/bin/bash
dnf update -y \
    && dnf install -y \
            cronie \
            git \
&& rm -rf /var/cache/dnf/
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# postgresql
dnf install -y postgresql15-server

sudo postgresql-setup initdb

sudo passwd postgres


# goenv
git clone https://github.com/syndbg/goenv.git ~/.goenv

echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc
echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc

echo 'export PATH="$GOROOT/bin:$PATH"' >> ~/.bashrc
echo 'export PATH="$PATH:$GOPATH/bin"' >> ~/.bashrc

echo 'eval "$(goenv init -)"' >> ~/.bashrc

goenv --version

goenv install 1.22.1
goenv versions
goenv global 1.22.1
