$WindowsVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId
if ($WindowsVersion -ne "2009") {
  Write-Host -ForeGroundColor Red "Votre version de Windows n'est pas compatible avec ce script."
  pause
  break
}

Write-Host -ForegroundColor Yellow "ATTENTION : Ce script va supprimer les téléchargements de plus de 30 jours pour TOUS LES UTILISATEURS !"
$Confirm = Read-Host "Êtes-vous sûr(e) de vouloir continuer ? (tapez OUI si vous souhaitez continuer)"
if ($Confirm -eq "OUI")
{
  $TailleAvant = ([math]::Round((get-PSDrive C).Free/1GB,2))
  Write-Host "I. Nettoyage des téléchargements pour tous les utilisateurs"
  $delai = 30
  $limit = (Get-Date).AddDays(-$delai)
  $users = get-childitem c:\users
  Write-Host "Nettoyage..."
  foreach ($user in $users)
  {
  Get-ChildItem -Path C:\Users\$user\Downloads\* -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force -Erroraction silentlycontinue
  Get-ChildItem -Path C:\Users\$user\Downloads\* -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
  }
  Write-Host -ForegroundColor Green "Nettoyage des téléchargements terminé !"
  sleep 3

  Write-Host "II. Nettoyage des caches des navigateurs Google Chrome, Mozilla Firefox et Internet Explorer pour tous les utilisateurs"
  dir C:\Users | select Name | Export-Csv -Path C:\users\$env:USERNAME\users.csv -NoTypeInformation
  $list=Test-Path C:\users\$env:USERNAME\users.csv
  Write-Host -ForegroundColor Yellow "Nettoyage des caches Firefox..."
  Write-Host -ForegroundColor cyan
  Import-CSV -Path C:\users\$env:USERNAME\users.csv -Header Name | foreach {
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\* -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache\*.* -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\entries\*.* -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\thumbnails\* -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\cookies.sqlite -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\webappsstore.sqlite -Recurse -Force -EA SilentlyContinue
          Remove-Item -path C:\Users\$($_.Name)\AppData\Local\Mozilla\Firefox\Profiles\*.default\chromeappsstore.sqlite -Recurse -Force -EA SilentlyContinue
          }
  Write-Host -ForegroundColor Green "Nettoyage des caches Firefox terminé !"
  Write-Host -ForegroundColor Yellow "Nettoyage des caches Chrome..."
  Write-Host -ForegroundColor cyan
  Import-CSV -Path C:\users\$env:USERNAME\users.csv -Header Name | foreach {
          Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue
          Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cache2\entries\*" -Recurse -Force -EA SilentlyContinue
          Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies" -Recurse -Force -EA SilentlyContinue
          Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Media Cache" -Recurse -Force -EA SilentlyContinue
          Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\Cookies-Journal" -Recurse -Force -EA SilentlyContinue
          # Comment out the following line to remove the Chrome Write Font Cache too.
          # Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Google\Chrome\User Data\Default\ChromeDWriteFontCache" -Recurse -Force -EA SilentlyContinue -Verbose
          }

  Write-Host -ForegroundColor Green "Nettoyage des caches Chrome terminé !"
  # Clear Internet Explorer
  Write-Host -ForegroundColor Yellow "Nettoyage des caches Internet Explorer..."
  Write-Host -ForegroundColor cyan
  Import-CSV -Path C:\users\$env:USERNAME\users.csv | foreach {
    Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Microsoft\Windows\WER\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item -path "C:\Users\$($_.Name)\AppData\Local\Temp\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item -path "C:\Windows\Temp\*" -Recurse -Force -EA SilentlyContinue
    Remove-Item -path "C:\`$recycle.bin\" -Recurse -Force -EA SilentlyContinue
          }
  Remove-Item -Path C:\users\$env:USERNAME\users.csv -Force
  Write-Host -ForegroundColor Green "Nettoyage des caches Internet Explorer terminé !"

  Write-Host -ForegroundColor Green "Nettoyage des caches navigateurs terminé !"
  sleep 2
  Write-Host "III. Nettoyage du cache Windows Update..."
  Write-Host "Arrêt de Windows Update..."
  net stop wuauserv
  Write-Host "Vidage du cache Windows Update..."
  Remove-Item C:\Windows\SoftwareDistribution\Download\*.* -Recurse -Force
  Write-Host "Démarrage de Windows Update..."
  net start wuauserv
  Write-Host -ForegroundColor Green "Nettoyage du cache Windows Update terminé !"
  Write-Host -ForegroundColor Green "Nettoyage de Windows terminé."
  $TailleApres = ([math]::Round((get-PSDrive C).Free/1GB,2))
  $EspaceGagne = $TailleApres - $TailleAvant
  $EspaceGagneRound = [math]::Round($EspaceGagne,2)
  Write-Host "Ce nettoyage a permis de récupérer $EspaceGagneRound Go !"
  pause
}
else{
break
}
