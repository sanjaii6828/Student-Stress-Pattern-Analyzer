# Launch the Student Stress Pattern Analyzer Web Dashboard in the default browser
$htmlPath = Join-Path $PSScriptRoot "frontend\index.html"
Write-Host "Opening Student Stress Pattern Analyzer Dashboard at: $htmlPath" -ForegroundColor Cyan
Start-Process $htmlPath

