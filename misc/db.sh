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

# ssh setting
ssh-keygen -t rsa -b 4096 -C "ec2-github" -f ~/.ssh/github_deploy_key

# ~/.ssh/configに下記を書き込み
 Host github.com
  IdentityFile ~/.ssh/github_deploy_key
  User git

# 接続確認
ssh -T git@github.com

cd /opt
git clone git@github.com:wanrun-develop/wanrun-migrate.git


aws ssm start-session \
    --target i-0dc2ba19951e1da20 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["5432"],"localPortNumber":["15432"]}'

# pgadmin setting
vim /var/lib/pgsql/data/pg_hba.conf
```
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5

# IPv4 local connections (Change "ident" to "md5")
host    all             all             127.0.0.1/32            md5

# IPv6 local connections (Change "ident" to "md5")
host    all             all             ::1/128                 md5

# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     md5
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5

# Allow connections from any source (Required for SSM Port Forwarding)
host    all             all             0.0.0.0/0               md5
```
