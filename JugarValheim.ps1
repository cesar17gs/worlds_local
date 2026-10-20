# ==========================================
# CONFIGURACIÓN DEL SCRIPT
# ==========================================
$valheimAppId = "892970"
$savePath     = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\worlds_local"

# 1. VERIFICAR RUTA
if (-not (Test-Path $savePath)) {
    Write-Host "[ERROR] No se encontró la carpeta de mundos de Valheim." -ForegroundColor Red
    Pause
    exit
}

# 2. SINCRONIZACIÓN INICIAL (PULL)
Set-Location $savePath
Write-Host "Sincronizando partida con GitHub..." -ForegroundColor Cyan
git pull origin main --rebase --autostash 2>&1 | Out-Null
Write-Host "[OK] Partida sincronizada correctamente." -ForegroundColor Green

# 3. LANZAMIENTO DE VALHEIM
Write-Host "Lanzando Valheim desde Steam..." -ForegroundColor Cyan
Start-Process "steam://rungameid/$valheimAppId"

# 4. PAUSA ACTIVA PARA JUGAR
Write-Host ""
Write-Host "=======================================================" -ForegroundColor Yellow
Write-Host " JUEGO EN CURSO... " -ForegroundColor Yellow
Write-Host " Cuando termines de jugar y cierres Valheim," -ForegroundColor Cyan
Write-Host " VUELVE A ESTA VENTANA Y PRESIONA ENTER." -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Yellow
Read-Host "Presiona [ENTER] solo cuando hayas cerrado el juego por completo"

# 5. GUARDADO Y PUSH FINAL A LA NUBE
Write-Host ""
Write-Host "Juego cerrado. Subiendo progreso final a la nube..." -ForegroundColor Cyan

Set-Location $savePath
git add .
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Auto-backup final al salir: $timestamp" 2>&1 | Out-Null
git push origin main

Write-Host "¡Partida sincronizada y subida a GitHub con éxito!" -ForegroundColor Green
Start-Sleep -Seconds 3