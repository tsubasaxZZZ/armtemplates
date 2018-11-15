# 展開する仮想マシン
- ドメイン コントローラー(DC) 1台
- リモート デスクトップ サーバー(RDSGW) 1台

# 環境
- 仮想ネットワーク
    - ネットワーク空間 : 10.0.0.0/16
    - サブネット(default) : 10.0.0.0/24
- DC
    - IP アドレス : 10.0.0.4(固定)
    - パブリック IP アドレス : 無し
- RDSGW
    - IP アドレス : 10.0.0.5(固定)
    - パブリック IP アドレス : 静的
    - NSG : 443のみオープン

# 制限事項
- 証明書の期間
- ライセンスの期間

# 展開方法
## 1. Azure CLI による展開
### ポータルから Cloud Shell を開く
ポータルの右上にあるボタンから Cloud Shell を開きます。

![cs](https://raw.githubusercontent.com/tsubasaxZZZ/armtemplates/master/create-rdsgw-environment/asset/cs.png)

### ストレージ アカウントの設定
ストレージ アカウントを選択する画面が出てきた場合、
[Azure Cloud Shell でファイルを永続化する](https://docs.microsoft.com/ja-jp/azure/cloud-shell/persisting-shell-storage) を参照し、Cloud Shell 用のストレージアカウントを準備します。

### リソースのダウンロード
次のコマンドを実行し、Cloud Shell 環境にファイルをダウンロードします。
```Bash
git clone https://github.com/tsubasaxZZZ/armtemplates.git
```

### リソース グループの作成
次のコマンドを実行し、リソース グループを作成します。(リソース グループ名、リージョンは任意のものを指定)
```Bash
az group create -g RDSGW-rg --location japaneast
```
※ポータルから作成しても問題ありません。

### 展開
次のコマンドを実行し、展開します。
```Bash
# ディレクトリの移動
cd armtemplates/create-rdsgw-environment/
# 展開の実行
az group deployment create -g resource-group --name deploymentname --template-file create_RDS_gateway.json --no-wait
# パラメーターの入力
#※ パスワードは大文字小文字数字を含んだ12桁以上にすること。
#※ dnsLabelPrefix は、DNS 名となるためユニークになるようにすること。
Please provide string value for 'adminUsername' (? for help): tsunomur
Please provide securestring value for 'adminPassword' (? for help):
Please provide string value for 'dnsLabelPrefix' (? for help): tsunomur1116
```

### 展開の完了
展開したリソース グループのメニューから、"デプロイ" を開き、展開が成功していることを確認します。

## 2. RDS Gateway の設定
### 自己署名証明署の作成
1. サーバー マネージャーから、Remote Desktop Gateway Manager を開きます。

![rdgwm1](https://raw.githubusercontent.com/tsubasaxZZZ/armtemplates/master/create-rdsgw-environment/asset/rdgwm1.PNG)

2. Remote Desktop Gateway Manager のサーバーを右クリックし、[Properties]を開きます。

![rdgwm2](https://raw.githubusercontent.com/tsubasaxZZZ/armtemplates/master/create-rdsgw-environment/asset/rdgwm2.PNG)

3. [SSL Certificate] タブを開きます。

4. [Create a self-signed certificate] を選択します。

5. [Certificate name:] に、RDSGW のパブリック IP アドレスを入力し、証明書を保存します。

![rdgwm3](https://raw.githubusercontent.com/tsubasaxZZZ/armtemplates/master/create-rdsgw-environment/asset/rdgwm3.PNG)

### 自己署名証明書のダウンロード
保存した証明書を、手元の環境にダウンロードします。

## 3. ユーザーの追加
ユーザーは、DC から追加します。
RDSGW で、リモートデスクトップ接続を起動し、接続先に[DC]を入力して接続します。

## 4. 接続元環境への証明書のインストール
1. ダウンロードした証明書を右クリックし、[証明書のインストール]を押下します。
2. ウィザードを進め、[証明書をすべて次のストアに配置する]を選択し、[信頼されたルート証明機関]にインストールします。

![cc](https://raw.githubusercontent.com/tsubasaxZZZ/armtemplates/master/create-rdsgw-environment/asset/cc.PNG)

## 5. RDP ファイルの編集
RDP-sample.rdp ファイルをテキストで開き、`gatewayhostname:s:<IP アドレス>` の IP アドレスの部分を RDSGW 仮想マシンのパブリック IP アドレスに変更します。

# テンプレート詳細
このテンプレートは以下のことを行います。

1. 診断ログ用のストレージ アカウントの作成
2. RDSGW 用のパブリック IP アドレスの作成
3. 仮想ネットワークの作成
4. ドメイン コントローラーと RDSGW の NIC の作成
5. RDSGW 用の NSG の作成
6. ドメイン コントローラーと RDSGW 用の仮想マシンの作成
7. [ドメイン コントローラー] PowerShell DSC 拡張でドメインに昇格
8. 仮想ネットワークの DNS の設定をドメイン コントローラーの IP アドレスに変更
9. [RDSGW] 拡張でドメインに参加
10. [RDSGW] PowerShell DSC 拡張で RDSSH、RDSGWをインストール