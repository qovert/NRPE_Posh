<#
.Synopsis
   Script to check backup status of Windows Server Backup and return status for Nagios
   via NSClient++
.DESCRIPTION
    Windows Server 2012+ posts these IDs to the Microsoft-Windows-Backup event log:
        Sourced from: https://technet.microsoft.com/en-us/library/cc734488(v=ws.10).aspx

    ID 1    (Information) BACKUP_STARTED
    ID 4    (Information) BACKUP_SUCCESS_EVENT
    ID 14   (Information) Backup operation completed (this doesn't record success or
                          failure, just 'completed')
   MSDN lists LogLevels as: 
        1 - Critical
        2 - Error 
        3 - Warning
        4 - Information 
   Script checks log levels and assigns returnstates based on their level. 
   
   Windows Server Backup posts an id for each individual backup failure for some 
   reason. For our purposes, all non-ID 4 returns will be considered 'Critical'.

   For testing purposes, the full script can be run and will produce expected output
   based on whether or not the last Windows Server Backup completed. 
.EXAMPLE
   Function is intended to be run as part of a larger script called by the NSClient service and 
   stored in C:\Program Files\NSClient++\scripts\
.EXAMPLE
   C:\Program Files\Nsclient++\scripts\BackupMonitor.ps1 
#>
function WinBackupMonitor {
    $returnStateOK = 0
    $returnStateWarn = 1
    $returnstateCrit = 2
    $returnStateUnknown = 3
    
    $events = Get-WinEvent -FilterHashtable `
        @{LogName='Microsoft-Windows-Backup';StartTime=(Get-Date).AddDays(-1)}
    foreach ($event in $events) {
        if ($event.level -eq '2' -or $event.level -eq '1'){
            $CritNbEv = 1
        }
        elseif ($event.level -eq '3') {
            $WarnNbEv = 1
        }
        elseif ($event.level -eq '4') {
            $OkNbEv = 1            
        }        
    }

    if ($CritNbEv -ne $null) {
        Write-Host 'CRITICAL - Found multiple errors in Microsoft-Windows-Backup event log'
        exit $returnstateCrit
    }
    elseif ($WarnNbEv -ne $null) {
        Write-Host 'Warning - Found issues in Microsoft-Windows-Backup event log'
        exit $returnStateWarn
    }
    elseif ($OkNbEv -ne $null) {
        Write-Host 'OK - No errors in Microsoft-Windows-Backup log'
        exit $returnStateOK
    }
    else {
        exit $returnStateUnknown
    }     
}

<#
.Synopsis
   Script to check backup status of BackupAssist products and return status for Nagios
   via NSClient++
.DESCRIPTION
   Script to check backup status of BackupAssist product and return status for Nagios
   BackupAssist posts these IDs to the Application event log:

    ID 5632 (Information) on when a backup job starts to run
    ID 5633 (Information) on success, or success with minor warnings
    ID 5634 (Error) on failure
    ID 5635 (Warning) on success but with major warnings (eg. wrong external HDD connected).

   For testing purposes, the full script can be run and will produce expected output
   based on whether or not the last Windows Server Backup completed. 
.EXAMPLE
   Function is intended to be run as part of a larger script called by the NSClient service and 
   stored in C:\Program Files\NSClient++\scripts\
.EXAMPLE
   C:\Program Files\Nsclient++\scripts\BackupMonitor.ps1 
#>
function BABackupMonitor {
    $returnStateOK = 0
    $returnStateWarn = 1
    $returnstateCrit = 2
    $returnStateUnknown = 3
   
    $events = Get-EventLog -LogName Application -Source 'BackupAssist' -After (Get-Date).AddDays(-1)
    foreach ($event in $events) {
        if ($event.InstanceId -eq '5634'){
            $CritNbEv = 1
        }
        elseif ($event.InstanceId -eq '5635') {
            $WarnNbEv = 1
        }
        elseif ($event.InstanceId -eq '5633') {
            $OkNbEv = 1            
        }        
    }

    if ($CritNbEv -ne $null) {
        Write-Host 'CRITICAL - Found multiple errors in BackupAssist event log'
        exit $returnstateCrit
    }
    elseif ($WarnNbEv -ne $null) {
        Write-Host 'Warning - Found issues in BackupAssist event log'
        exit $returnStateWarn
    }
    elseif ($OkNbEv -ne $null) {
        Write-Host 'OK - No errors in BackupAssist log'
        exit $returnStateOK
    }
    else {
        exit $returnStateUnknown
    }  
}

$isBAinst = Test-Path 'C:\Program Files (x86)\BackupAssist*'

if ($isBAinst -eq $true) {
    BABackupMonitor }
else {
    WinBackupMonitor }