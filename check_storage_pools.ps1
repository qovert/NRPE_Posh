$NagiosStatus = "3"
$NagiosDescription = ""

$disks = Get-PhysicalDisk | Sort FriendlyName | select FriendlyName,HealthStatus,OperationalStatus,SerialNumber
$pools = Get-StoragePool | Sort FriendlyName | select FriendlyName,HealthStatus,OperationalStatus

foreach ($pool in $pools) {
    switch ($pool.HealthStatus,$pool.OperationalStatus) {
        Healthy {$health = 'OK'; $NagiosStatus = '0' } 
        Warning {$health = 'Warning'; $NagiosStatus = '1'} 
        Unhealthy {$health = 'Unhealthy'; $NagiosStatus = '2'}
        OK {$oper = 'OK'; $NagiosStatus = '0';}
        Stressed {$oper = 'Warning'; $NagiosStatus = '1'}
        Degraded {$oper = 'Unhealthy'; $NagiosStatus = '2'} 
    }

    $NagiosDescription = $NagiosDescription + "(POOL:"+$pool.FriendlyName+" Health:"+$health+" Operational:"+$oper+") "
}

foreach ($disk in $disks) {
    switch ($disk.HealthStatus,$disk.OperationalStatus) {
        Healthy {$health = 'OK'; $NagiosStatus = '0' } 
        Warning {$health = 'Warning'; $NagiosStatus = '1'} 
        Unhealthy {$health = 'Unhealthy'; $NagiosStatus = '2'}
        OK {$oper = 'OK'; $NagiosStatus = '0';}
        default {$oper = 'Unhealthy'; $NagiosStatus = '2'}
    }

    $NagiosDescription = $NagiosDescription + "(DISK:"+$disk.SerialNumber+" Health:"+$health+" Operational:"+$oper+") "
}

switch ($NagiosStatus) {
    0 {"Healthy: $NagiosDescription"}
    1 {"Warning: $NagiosDescription"}
    2 {"Critical: $NagiosDescription"}
    default {'Unknown: Please check manually'}
}

exit $NagiosStatus