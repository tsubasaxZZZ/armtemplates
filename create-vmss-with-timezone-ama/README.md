# タイムゾーンを指定した VMSS の展開

## 前提
- VNet が展開されていること
- カスタムのイメージが展開されていること
- Log Analytics が展開されていること
- データ収集ルールが展開されていること
- 送信接続を制御する場合は、`AzureMonitor` と `Storage` が許可されていること

## 展開方法

```bash
az deployment group create --resource-group rg-vmss --template-file main.bicep --name $RANDOM --parameters @azuredeploy.parameter.json
```