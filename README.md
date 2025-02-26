# wanrun-terraform

## 運用ルール
- `terraform fmt -recursive`で必ずしてpushする(今度、GHAで自動フォーマッター入れる)

## ローカルPCのpgAdminでwanrunのDB(EC2)に繋ぐ方法

### ssm agentローカルMacにインストール(ない場合)
brew install session-manager-plugin

### ローカルSSMのコマンド
 avw aws ssm start-session \
    --target i-0dc2ba19951e1da20 \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["5432"],"localPortNumber":["15432"]}'

### pgAdmin設定
Host name/address: 127.0.0.1
Port: 15432
Maintenance: postgres
Username: postgres
