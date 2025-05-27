param(
    [string]$User = 'Exited3n',
    [int]$MaxEvents = 500,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
Usage of the script token_type2.ps1:

Parameters:
  -User       Username to filter events by (default: 'Exited3n')
  -MaxEvents  Maximum number of events to display (default: 500)
  -Help       Display this help message

Examples:
  .\token_type2.ps1 -User 'Administrator' -MaxEvents 1000
  .\token_type2.ps1 -User 'Admin'
"@
}

if ($Help) {
    Show-Help
    exit 0
}

try {
    Write-Host "Filtering events for user: $User"
    Write-Host "Maximum number of events to display: $MaxEvents"
    Write-Host "For help, run: .\token_type2.ps1 -Help"
    Write-Host ""

    # Fetch more events to ensure enough after filtering
    $fetchCount = $MaxEvents * 5
    $events = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents $fetchCount -ErrorAction Stop

    $results = $events | ForEach-Object {
        $eventXml = [xml]$_.ToXml()
        $targetUser = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' } | Select-Object -ExpandProperty '#text'

        if ($targetUser -imatch $User) {
            $logonType = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'LogonType' } | Select-Object -ExpandProperty '#text'
            $logonId = $eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetLogonId' } | Select-Object -ExpandProperty '#text'

            [PSCustomObject]@{
                TimeCreated     = $_.TimeCreated
                LogonType       = $logonType
                TargetUserName  = $targetUser
                LogonID         = $logonId
            }
        }
    } | Where-Object { $_ -ne $null } | Select-Object -First $MaxEvents

    if ($results.Count -eq 0) {
        Write-Warning "No events found for user '$User'."
    }
    else {
        $results | Format-Table -AutoSize
    }
}
catch {
    Write-Error "An error occurred while retrieving events: $_"
    Write-Error "Please ensure you have access to the Security log and that parameters are correct."
}
