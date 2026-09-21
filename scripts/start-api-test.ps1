# TEST ONLY: runs grails.env=test with temporary H2 data on port 8081.
# Use start-backend-mysql.ps1 for the real website/MySQL data.
$ErrorActionPreference = 'Stop'
$projectDir = Split-Path $PSScriptRoot -Parent
$socketDir = Join-Path $projectDir '.tmp'
New-Item -ItemType Directory -Force $socketDir | Out-Null
$previousJavaOptions = $env:JAVA_TOOL_OPTIONS
try {
    $env:JAVA_TOOL_OPTIONS = "-Djdk.net.unixdomain.tmpdir=$socketDir -Dgrails.env=test"
    & (Join-Path $projectDir 'backend/library_System-main/gradlew.bat') -p (Join-Path $projectDir 'backend/library_System-main') bootRun --args=--server.port=8081 --console=plain
} finally {
    $env:JAVA_TOOL_OPTIONS = $previousJavaOptions
}
