# ==========================================
# CONFIGURACIÓN DEL SCRIPT
# ==========================================
$valheimAppId = "892970"
$savePath     = "$env:USERPROFILE\AppData\LocalLow\IronGate\Valheim\worlds_local"
$intervalMin  = 10   # Intervalo de respaldo local (minutos)
$pushInterval = 3    # Hacer push a la nube cada X backups locales (3 = cada 30 mins)

# Función para enviar notificaciones de Windows
function Send-Notification {
    param([string]$Title, [string]$Message)
    try {
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $notification = New-Object System.Windows.Forms.NotifyIcon
        $notification.Icon = [System.Drawing.SystemIcons]::Information
        $notification.BalloonTipTitle = $Title
        $notification.BalloonTipText = $Message
        $notification.Visible = $True
        $notification.ShowBalloonTip(3000)
        Start-Sleep -Seconds 3
        $notification.Dispose()
    } catch {
        # Si falla el Toast, simplemente no detiene el script
    }
}

# ==========================================
# 1. VERIFICACIONES INICIALES
# ==========================================
Write-Host "Iniciando verificaciones del sistema..." -ForegroundColor Cyan

if (-not (Test-Path $savePath)) {
    Write-Host "[ERROR] No se encontró la carpeta de mundos de Valheim en: $savePath" -ForegroundColor Red
    Pause
    exit
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Git no está instalado o no está en el PATH." -ForegroundColor Red
    Pause
    exit
}

# ==========================================
# 2. SINCRONIZACIÓN INICIAL (PULL)
# ==========================================
Set-Location $savePath
Write-Host "Sincronizando partida con GitHub..." -ForegroundColor Cyan

$pullResult = git pull origin main --rebase --autostash 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ADVERTENCIA] Hubo un problema al descargar los cambios. Verifica tu conexión o posibles conflictos." -ForegroundColor Yellow
} else {
    Write-Host "[OK] Partida sincronizada correctamente." -ForegroundColor Green
}

# ==========================================
# 3. LANZAMIENTO DE VALHEIM
# ==========================================
Write-Host "Lanzando Valheim desde Steam..." -ForegroundColor Cyan
Start-Process "steam://rungameid/$valheimAppId"

# Esperar a que arranque el proceso
$process = $null
while (-not $process) {
    Start-Sleep -Seconds 2
    $process = Get-Process -Name "valheim" -ErrorAction SilentlyContinue
}

Send-Notification -Title "Valheim Sync" -Message "Juego iniciado. Sincronización automática activada cada $intervalMin minutos."

# ==========================================
# 4. BUCLE DE AUTO-RESPALDO EN SEGUNDO PLANO
# ==========================================
$backupCount = 0

while (-not $process.HasExited) {
    # Esperar el intervalo configurado
    Start-Sleep -Seconds ($intervalMin * 60)
    
    $process.Refresh()
    if ($process.HasExited) { break }

    $backupCount++
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    Set-Location $savePath
    git add .
    
    # Realizar commit local
    $commitMsg = "Auto-backup periódico ($timestamp)"
    git commit -m $commitMsg 2>&1 | Out-Null
    
    # Cada X backups locales, hacer un push preventivo a la nube
    if ($backupCount % $pushInterval -eq 0) {
        git push origin main 2>&1 | Out-Null
        Send-Notification -Title "Valheim Sync" -Message "Respaldo #$backupCount realizado y guardado en la nube."
    } else {
        Send-Notification -Title "Valheim Sync" -Message "Respaldo local #$backupCount realizado."
    }
}

# ==========================================
# 5. GUARDADO Y PUSH FINAL AL CERRAR
# ==========================================
Write-Host "Juego cerrado. Realizando guardado final..." -ForegroundColor Cyan
Send-Notification -Title "Valheim Sync" -Message "Subiendo progreso final a la nube..."

Set-Location $savePath
git add .
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "Auto-backup final al salir: $timestamp" 2>&1 | Out-Null
git push origin main

Send-Notification -Title "Valheim Sync" -Message "¡Partida sincronizada y subida a la nube con éxito!"
Write-Host "¡Todo listo! Cierre de sincronización completo." -ForegroundColor Green
Start-Sleep -Seconds 3