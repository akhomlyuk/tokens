Get-WmiObject -Class Win32_LogonSession | 
Where-Object { $_.LogonType} | 
ForEach-Object {
    $session = $_
    Get-WmiObject -Query "Associators of {Win32_LogonSession.LogonId='$($session.LogonId)'} Where AssocClass=Win32_LoggedOnUser Role=Dependent" | 
    Select-Object @{n='User';e={$_.Name}}, @{n='LogonType';e={$session.LogonType}}
}
