Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents 10 | 
ForEach-Object {
    $eventXml = [xml]$_.ToXml()
    $logonType = $eventXml.Event.EventData.Data | 
        Where-Object { $_.Name -eq 'LogonType' } | 
        Select-Object -ExpandProperty '#text'
    
    $targetUser = $eventXml.Event.EventData.Data | 
        Where-Object { $_.Name -eq 'TargetUserName' } | 
        Select-Object -ExpandProperty '#text'
    
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated
        LogonType = $logonType
        TargetUserName = $targetUser
        LogonID = ($eventXml.Event.EventData.Data | 
            Where-Object { $_.Name -eq 'TargetLogonId' }).'#text'
    }
} | Format-Table -AutoSize
