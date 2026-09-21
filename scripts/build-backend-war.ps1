$ErrorActionPreference = 'Stop'

$projectDir = Split-Path $PSScriptRoot -Parent
$backendDir = Join-Path $projectDir 'backend/library_System-main'

& (Join-Path $backendDir 'gradlew.bat') -p $backendDir clean war --console=plain

Write-Host ''
Write-Host 'WAR files:'
Get-ChildItem (Join-Path $backendDir 'build/libs') -Filter '*.war' | ForEach-Object {
    Write-Host $_.FullName
}
