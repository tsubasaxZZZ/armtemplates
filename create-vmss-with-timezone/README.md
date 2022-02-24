# タイムゾーンを指定した VMSS の展開

## 前提
- VNet が展開されていること
- カスタムのイメージが展開されていること

## 展開方法

```bash
az deployment group create --resource-group rg-vmss --template-file main.bicep --name $RANDOM --parameters @azuredeploy.parameter.json
```