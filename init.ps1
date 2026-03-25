# init.ps1
# This script initializes and starts both the Node.js backend and the Flutter frontend.

Write-Host "========================================="
Write-Host "Starting Municipal Workforce Management"
Write-Host "========================================="

# Start Backend in a new window
Write-Host "1. Installing backend dependencies and starting server..."
Start-Process powershell -ArgumentList "-NoExit -Command `"cd backend; npm install; npm run dev`""

# Start Frontend in a new window
Write-Host "2. Fetching frontend packages and starting Flutter app..."
Start-Process powershell -ArgumentList "-NoExit -Command `"cd smart_civic; flutter pub get; flutter run -d chrome`""

Write-Host "Both servers are starting in separate windows!"
