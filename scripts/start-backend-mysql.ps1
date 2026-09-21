$ErrorActionPreference = 'Stop'

$projectDir = Split-Path $PSScriptRoot -Parent
$backendDir = Join-Path $projectDir 'backend/library_System-main'
$socketDir = Join-Path $projectDir '.tmp'
New-Item -ItemType Directory -Force $socketDir | Out-Null

$previousJavaOptions = $env:JAVA_TOOL_OPTIONS
try {
    # Development = the same MySQL datasource used by the website.
    # application.yml currently points development to ubs_training.
    $env:JAVA_TOOL_OPTIONS = "-Djdk.net.unixdomain.tmpdir=$socketDir -Dgrails.env=development"
    & (Join-Path $backendDir 'gradlew.bat') -p $backendDir bootRun --args=--server.port=8080 --console=plain
} finally {
    $env:JAVA_TOOL_OPTIONS = $previousJavaOptions
}
