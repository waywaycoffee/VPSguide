# Fix Clash Verge service - run as Administrator
# powershell -ExecutionPolicy Bypass -File C:\Users\19802\restart-clash-service.ps1

$ErrorActionPreference = "Continue"

Write-Host "=== Fix Clash Verge Service ===" -ForegroundColor Cyan

Write-Host "[1/5] Stop conflicting processes..." -ForegroundColor Yellow
Stop-Process -Name fcclientCore -Force -ErrorAction SilentlyContinue
Stop-Process -Name clash-verge -Force -ErrorAction SilentlyContinue
Stop-Process -Name verge-mihomo -Force -ErrorAction SilentlyContinue
Start-Sleep 2

Write-Host "[2/5] Restart clash_verge_service..." -ForegroundColor Yellow
sc.exe stop clash_verge_service 2>$null
Start-Sleep 3
sc.exe start clash_verge_service 2>&1
Start-Sleep 5

Write-Host "[3/5] Start Clash Verge..." -ForegroundColor Yellow
Start-Process "C:\Program Files\Clash Verge\clash-verge.exe"
Start-Sleep 12

Write-Host "[4/5] Wait for port 7897..." -ForegroundColor Yellow
$ready = $false
for ($i = 0; $i -lt 25; $i++) {
    $listen = netstat -ano | Select-String "127.0.0.1:7897.*LISTENING"
    if ($listen) { $ready = $true; break }
    Start-Sleep 2
}

Write-Host "[5/5] Test proxy..." -ForegroundColor Yellow
if ($ready) {
    $ip = curl.exe -s --max-time 15 -x http://127.0.0.1:7897 https://ipinfo.io/json 2>&1
    Write-Host $ip
    if ($ip -match 'country.*US') {
        Write-Host ""
        Write-Host "OK - proxy works. Select codex in Clash proxy page." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Core is up. In Clash: codex-vps -> Use -> select codex" -ForegroundColor Yellow
    }
} else {
    Write-Host ""
    Write-Host "7897 not listening. Manual steps:" -ForegroundColor Red
    Write-Host "  1. Run Clash Verge as Administrator"
    Write-Host "  2. Settings -> Reinstall service"
    Write-Host "  3. Settings -> Restart core as Administrator"
}

Write-Host ""
Write-Host "Done."
