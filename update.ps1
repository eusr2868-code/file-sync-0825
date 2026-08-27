$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$Host.UI.RawUI.WindowTitle = '一键更新到桌面包'

$DEST = 'C:\Users\Administrator\Desktop\包'
$TMP  = Join-Path $env:TEMP 'huan_update.zip'
$urls = @(
  'https://cdn.jsdelivr.net/gh/eusr2868-code/file-sync-0825@main/huan.zip',
  'https://github.com/eusr2868-code/file-sync-0825/releases/latest/download/huan.zip',
  'https://gh-proxy.com/https://github.com/eusr2868-code/file-sync-0825/releases/latest/download/huan.zip'
)

Write-Host '============================================'
Write-Host '  自动下载更新包，并替换到：'
Write-Host "  $DEST"
Write-Host '============================================'
Write-Host ''

New-Item -ItemType Directory -Force -Path $DEST | Out-Null

$ok = $false
foreach ($u in $urls) {
  Write-Host '[1/3] 正在下载更新包（国内CDN，无需梯子）...'
  try {
    $wc = New-Object System.Net.WebClient
    $wc.Headers.Add('User-Agent', 'Mozilla/5.0')
    $wc.DownloadFile($u, $TMP)
    $len = (Get-Item $TMP).Length
    if ($len -gt 1000) { $ok = $true; break }
    Remove-Item $TMP -Force -ErrorAction SilentlyContinue
  } catch {
    Remove-Item $TMP -Force -ErrorAction SilentlyContinue
  }
}
if (-not $ok) {
  Write-Host ''
  Write-Host '[失败] 所有下载通道都失败了，请检查网络后重试。'
  exit 1
}

Write-Host '  下载完成。'
Write-Host '[2/3] 正在解压并替换文件...'
try {
  Expand-Archive -LiteralPath $TMP -DestinationPath $DEST -Force
} catch {
  Write-Host "[失败] 解压替换失败：$($_.Exception.Message)"
  exit 1
}
Remove-Item $TMP -Force -ErrorAction SilentlyContinue

Write-Host '[3/3] 全部完成！文件已替换到：'
Write-Host "  $DEST"
Write-Host ''
exit 0
