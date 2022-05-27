# Export the Current Registry Profile List on the device
reg export 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' 'C:\profilelist_Check.reg' /y
$users = Get-CimInstance -Class Win32_UserProfile | Select-Object LocalPath, SID
$computerName = $env:ComputerName

#List of Users who you are not concerned about. These might be users that exist on both domains, but were not migrated.
$invalidUsers = @('admin1','admin2')

#These are the SIDS of users on the new domain that might have had their name changed as a result of a marriage/divorce.
$marriageSIDS = "SID1", "SID2"

$ToClean = @()
$ToDelete = @{}

#Enter your domain name information here, including the leading period
$oldDomain = ".oldDomain"
$newDomain = ".newDomain"

foreach ($user in $users) { 
    $currentUser = Split-Path $user.LocalPath -Leaf
    # Removes the period and everything after for new and old domain names. Sometimes user folder paths contain this information
    if (($currentUser -match $oldDomain) -or ($currentUser -match $newDomain) -or ($currentUser -match $computerName)) {
      $pos = $currentUser.IndexOf(".")
      $currentUser = $currentUser.Substring(0,$pos)
    }

    Write-Host $currentUser

    # Validate account
    if (($user.LocalPath -match "users") -and ($currentUser -notin $invalidUsers)) {
        # Get the SID of the username $currentUser
        $currentUserSID = Get-WmiObject Win32_UserAccount -Filter "Name='$currentUser' and Domain='$env:USERDOMAIN'"
        $currentUserSID = $currentUserSID.SID

        # If the user acccount matches, just write to host they are valid
        if ($currentUserSID -match $user.SID) {
            Write-Host "The user SIDs match for" $currentUser " | " $currentUserSID "|" $user.SID 

        # If they don't match, then the SID is invalid or user account wasn't found.
        } else {
            Write-Host $currentUser "'sSID" $currentUserSID "does not match " $user.SID "| User profile will be double checked"
            $ToDelete.add($User.SID, $currentUser)
        }
    } else {
      Write-Host "User is invalid"
    }
    Write-Host "-----------------------" -BackgroundColor "Cyan" -ForegroundColor "White"

}

#Search the hashtable for known good-SIDS that wont show up above due to marriage or user renames
$ToDelete.GetEnumerator() | ForEach-Object {
    
    if ($_.key -in $marriageSIDS ){
        Write-Host "Found! for" $_.key "&" $_.value
        Write-Host "Removing from delete hashtable..."
        $ToClean += $_.key
    }
}

foreach($item in $ToClean) {
    $ToDelete.Remove($item)
}

Write-Host $ToDelete

#Delete Registry for Profiles
foreach($item in $ToDelete.Keys){
$regpath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\' + $item
Remove-Item -Path $regpath
}


