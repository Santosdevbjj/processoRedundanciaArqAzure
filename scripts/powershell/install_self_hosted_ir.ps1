# Script para instalar o Self-hosted Integration Runtime
$downloadUrl = "https://go.microsoft.com/fwlink/?linkid=2155943"
$installerPath = "$env:TEMP\IntegrationRuntime.msi"

Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath
Start-Process msiexec.exe -ArgumentList "/i $installerPath /quiet /qn" -Wait

Write-Host "Integration Runtime instalado. Configure usando a chave gerada no Azure Data Factory."
