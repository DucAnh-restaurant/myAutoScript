1. Open powershell 
Start-Process powershell -Verb RunAs -> Yes (To administrator)

2. Run Set-ExecutionPolicy Bypass -Scope Process -Force
3. .\install.ps1 -includeBase
