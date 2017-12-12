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

## デプロイ方法

### PowerShell

```PowerShell
> New-AzureRmResourceGroupDeployment -name test -TemplateFile CreateManyVM_ManagedDisk.json -TemplateParameterFile CreateManyVM_ManagedDisk_parameter.json -ResourceGroupName test1212
```