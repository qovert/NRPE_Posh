$NagiosStatus = '3'
$NagiosDescription = ""

$Events = Get-WinEvent -FilterXPath "Event[ System[ (Level=2 or Level=3) and (EventID=5827 or EventID=5828 or EventID=5829 or EventID=5830 or EventID=5831) ] ] ]"
if(!$Events){
	  $NagiosStatus = '0'
	  $NagiosDescription = 'Healthy - No events found'
} else {
    $NagiosDescription = "Unhealthy - Events found. Immediate action required"
	  $NagiosStatus = '2'
}

switch ($NagiosStatus) {
    0 {"Healthy: $NagiosDescription"}
    1 {"Warning: $NagiosDescription"}
    2 {"Critical: $NagiosDescription"}
    default {'Unknown: Please check manually'}
}

exit $NagiosStatus
