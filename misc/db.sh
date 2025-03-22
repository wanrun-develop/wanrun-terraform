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

## DBの設定
# 接続
psql -U postgres

# 権限系のSQL実行
# db作成
create database wanrun;

# db確認
\l 
# db指定
\c wanrun;
# スキーマ作成
CREATE SCHEMA wanrun;

# application 用ユーザー
# ユーザーの作成
CREATE ROLE wanrun WITH LOGIN PASSWORD 'wanrun';

# データベースCONNECT権限
REVOKE CONNECT ON DATABASE wanrun FROM PUBLIC; --全ロールの権限剥奪
GRANT CONNECT ON DATABASE wanrun TO wanrun;

# スキーマUSAGE権限
GRANT USAGE ON SCHEMA wanrun TO wanrun;
GRANT CREATE ON SCHEMA wanrun TO wanrun;

# テーブル操作権限
# すでにあるテーブルに権限を付与
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wanrun TO wanrun;
# 今後作成されるテーブルにも自動で権限を付与
ALTER DEFAULT PRIVILEGES IN SCHEMA wanrun GRANT ALL PRIVILEGES ON TABLES TO wanrun;

# シーケンス権限
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA wanrun TO wanrun;
ALTER DEFAULT PRIVILEGES IN SCHEMA wanrun GRANT USAGE, SELECT ON SEQUENCES TO wanrun;

ALTER ROLE wanrun SET search_path TO "wanrun";


# debug用ユーザー
# ユーザー作成
CREATE ROLE wanrundebug WITH LOGIN PASSWORD 'wanrundebug';

# データベースCONNECT権限
GRANT CONNECT ON DATABASE wanrun TO wanrundebug;

# スキーマUSAGE権限
GRANT USAGE ON SCHEMA wanrun TO wanrundebug;

# テーブル操作権限
# すでにあるテーブルに権限を付与
GRANT SELECT ON ALL TABLES IN SCHEMA wanrun TO wanrundebug;
# 今後作成されるテーブルにも自動で権限を付与
ALTER DEFAULT PRIVILEGES IN SCHEMA wanrun GRANT SELECT ON TABLES TO wanrundebug;

# シーケンス権限
GRANT SELECT ON ALL SEQUENCES IN SCHEMA wanrun TO wanrundebug;
ALTER DEFAULT PRIVILEGES IN SCHEMA wanrun GRANT SELECT ON SEQUENCES TO wanrundebug;

ALTER ROLE wanrundebug SET search_path TO "wanrun";

# 接続解除
exit


## migration実行
cd /opt/wanrun-migrate
go run migrate.go up

## dogful migration実行
cd ./dogful
go run migrate.go

# /var/lib/pgsql/data/postgresql.confで下記のコメントアウトを外す
```
listen_addresses = '*'
port = 5432                    # ポート番号。コメントアウトされていないことを確認する
max_connections = 100          # 最大接続数
shared_buffers = 128MB         # メモリ設定
```
