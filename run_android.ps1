$WSL_IP = (wsl hostname -I).Trim().Split(' ')[0]

Write-Host "WSL IP: $WSL_IP"
Write-Host "Starting Flutter..."

flutter run --dart-define=API_BASE_URL=http://${WSL_IP}:8080/LibrarySystem