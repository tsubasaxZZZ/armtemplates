## 概要
- 管理ディスクから作成されたイメージから仮想マシンを展開
- パラメーターで指定された数の仮想マシンを作成
- 既にある仮想ネットワークへの所属、もしくは、新規の仮想ネットワークを作成


## 必要条件
- 管理ディスクで作成されたイメージ
- GitHub へのアクセス環境
    - テンプレートリンクで、GitHub 上のファイルを参照しているため
    - テンプレート先のファイルを、サブスクリプションの Azure 環境からアクセスできる場所に保存することで、GitHub へのアクセスが不要
- 既存の仮想ネットワークへの所属の場合、同一リージョンであること

## オプション
### カスタムイメージ
カスタムイメージを使う時は、イメージ指定に以下を使う。

```json
"imageReference":{ "id" : "[parameters('imageResourceID')]"}, 
```
### 既存VNetへの参加
既存VNetへ参加する場合は、以下パラーメーターを指定する。既存VNetへ参加しない場合は無視される。

```json
    "addressPrefix" : {
        "value": "10.5.1.0/24"
    },
    "subnetPrefix" : {
        "value": "10.5.1.0/24"
    },
```

## デプロイ方法

### Azure PowerShell

```PowerShell
> New-AzureRmResourceGroupDeployment -name test -TemplateFile CreateManyVM_ManagedDisk.json -TemplateParameterFile CreateManyVM_ManagedDisk_parameter.json -ResourceGroupName test1212
```

### Azure CLI

```bash
> az group deployment create --name a  -g poc0213 --template-file CreateManyVM_ManagedDisk.json --parameters CreateManyVM_ManagedDisk_parameter.json
```