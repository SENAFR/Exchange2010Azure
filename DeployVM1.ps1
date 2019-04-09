#Remember to change DNS name, VM machine name and type in the template




#get-module -listavailable azurermget-az
##Set-ExecutionPolicy -ExecutionPolicy remotesigned
$creds = Get-Credential -UserName kieron.palmer@googlemail.com -Message "sign in"
Connect-AzAccount -Credential $creds

#Create Resource Group
$location = "UK South"
$RGName = "Exchange2010Lab"


Enable-AzureRmAlias

New-AzResourceGroup -Name $RGName -Location $location -force

#CreateStorageAccount and Container
$storageName = "st" + (Get-Random)
New-AzStorageAccount -ResourceGroupName $RGName -AccountName $storageName -Location $location -SkuName "Standard_LRS" -Kind Storage
$accountKey = (Get-AzStorageAccountKey -ResourceGroupName $RGName -Name $storageName).Value[0]
$context = New-AzureStorageContext -StorageAccountName $storageName -StorageAccountKey $accountKey 
New-AzureStorageContainer -Name "templates" -Context $context -Permission Container

Set-AzureStorageBlobContent -File ".\azuredeploy.json" -Context $context -Container "templates"
Set-AzureStorageBlobContent -File ".\azuredeploy.parameters.json" -Context $context -Container templates

$templatePath = "https://" + $storageName + ".blob.core.windows.net/templates/azuredeploy.json"
$parametersPath = "https://" + $storageName + ".blob.core.windows.net/templates/azuredeploy.parameters.json"
New-AzResourceGroupDeployment -ResourceGroupName $RGName -Name "myDeployment" -TemplateUri $templatePath -TemplateParameterUri $parametersPath