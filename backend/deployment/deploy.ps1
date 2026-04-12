# Configuración de Despliegue - AgroForecast.Api
$ErrorActionPreference = "Stop"
$ServerUser = "root"
$ServerHost = "72.60.241.246"
$RemotePath = "/var/www/agroforecast"
$LocalPublishPath = Join-Path $PSScriptRoot "..\AgroForecast.Api\publish"
$ProjectFile = Join-Path $PSScriptRoot "..\AgroForecast.Api\AgroForecast.API.csproj"
$ZipFile = Join-Path $PSScriptRoot ".\deploy_agro.zip"

Write-Host "--- Iniciando Despliegue Optimizado de AgroForecast ---" -ForegroundColor Cyan

# 1. Compilar y Publicar
Write-Host "[1/4] Compilando aplicación en perfil Release..." -ForegroundColor Yellow
if (Test-Path $LocalPublishPath) { Remove-Item -Path $LocalPublishPath -Recurse -Force -ErrorAction SilentlyContinue }

dotnet publish $ProjectFile -c Release -o $LocalPublishPath
if ($LASTEXITCODE -ne 0) {
    Write-Error "Error crítico en la compilación. Deteniendo despliegue."
    exit 1
}

# Pequeña pausa para permitir que Windows Defender o Visual Studio liberen los archivos recién creados
Start-Sleep -Seconds 3

# 2. Comprimir Archivos a ZIP
Write-Host "[2/4] Comprimiendo binarios a deploy.zip..." -ForegroundColor Yellow
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
Compress-Archive -Path "$LocalPublishPath\*" -DestinationPath $ZipFile -Force

# 3. Subir Archivo ZIP vía SCP
Write-Host "[3/4] Enviando archivo postal al servidor de Hostinger vía SCP..." -ForegroundColor Yellow
Write-Host "*(Probablemente el servidor te preguntará tu clave de Hostinger N35t0rp3na aquí)*" -ForegroundColor DarkGray
scp $ZipFile ${ServerUser}@${ServerHost}:/tmp/deploy_agro.zip

if ($LASTEXITCODE -ne 0) {
    Write-Error "Fallo en la conexión de subida. Verifica tu IP, Usuario y Contraseña de Hostinger."
    exit 1
}

# 4. Comandos Remotos: Descomprimir y Reiniciar el Servicio C#
Write-Host "[4/4] Limpiando carpetas viejas en Hostinger, extrayendo ZIP y Reiniciando el motor .NET..." -ForegroundColor Yellow
Write-Host "*(Probablemente el servidor te preguntará tu clave otra vez)*" -ForegroundColor DarkGray

$RemoteCommands = "mkdir -p $RemotePath; find $RemotePath -mindepth 1 -delete; unzip -q -o /tmp/deploy_agro.zip -d $RemotePath; rm /tmp/deploy_agro.zip; chown -R www-data:www-data $RemotePath; systemctl restart agroforecast.service; systemctl status agroforecast.service --no-pager"

ssh ${ServerUser}@${ServerHost} $RemoteCommands

# Limpieza local para no ensuciar el proyecto
Remove-Item $ZipFile -Force

Write-Host "--- 🎉 API DE AGROFORECAST DESPLEGADA EXITOSAMENTE EN HOSTINGER 🎉 ---" -ForegroundColor Green
Pause
