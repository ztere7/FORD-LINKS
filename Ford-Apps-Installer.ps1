do {

		[Net.ServicePointManager]::SecurityProtocol = `
    [Net.SecurityProtocolType]::Tls12, `
    [Net.SecurityProtocolType]::Tls13

    "FORD APPLICATIONS INSTALLER/UPDATER"
    "Version 1.0.1"
    "Check for updates at https://github.com/ztere7/FORD-LINKS"
    Write-Output ""


    $apps = Get-ItemProperty `
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
    Where-Object { $_.DisplayName -like "*ids*" -or $_.DisplayName -like "*fjds*" -or $_.DisplayName -like "*fdrs*" }

    "Checking IDS/FJDS/FDRS versions currently installed..."
    Write-Output ""

    $apps | Select-Object DisplayName, DisplayVersion
    Write-Output ""

    if (! $apps) {
        "IDS, FJDS, FDRS not currently installed"
        Write-Output ""
        Write-Output ""
    }
    $url = "https://raw.githubusercontent.com/ztere7/FORD-LINKS/refs/heads/main/downloadables.html"
    $response = Invoke-WebRequest -Uri $url
    $links = $response.Links
    "Checking for available apps to download..."
    Write-Output ""

    $counter = 1
    $menuMap = @{}

    foreach ($link in $links) {
        $appName = $link.innerHTML
        $appLink = $link.href
        Write-Output "$counter. $appName | $appLink"
        Write-Output ""
        $menuMap[$counter] = @{ Name = $appName; Url = $link.href}
        $counter++
    }

    $userChoice = Read-Host "Enter the number of the application you would like to install (or 0 to exit)"
    $userChoice = [int]$userChoice

    if ($userChoice -eq 0) {return $false}

    if ($menuMap.ContainsKey($userChoice)) {
        $selected = $menuMap[$userChoice]
        $fileName = "$env:TEMP\$($selected.Url.Split('/')[-1])"
        Write-Output "Downloading $($selected.Name) at $($selected.Url) to $fileName..."
        Start-BitsTransfer -Source $selected.Url -Destination $fileName
        Write-Output "Download complete! Launching installer..."
        Write-Output ""
        Write-Output ""

        Start-Process -FilePath $fileName
        Write-Output "$($selected.Name) installer finished."
    }
    else {
    Write-Output ""
    Write-Output "Invalid Selection"}

    Write-Output ""
    Write-Output ""
    Write-Output ""
    Write-Output ""
}

while($true)