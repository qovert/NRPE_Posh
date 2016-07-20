<# This script is intended to be called by nsclient++ agent for Nagios
   Script checks local machine's certificate store for certificates exipiring
   within 60 or 30 days.  
   
   If the certificate is due to expire in 60 days, it returns 
   a Warning state. 
   
   If the certificate is due to expire in 30 days, it returns a critical state.
   #>

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2

$certCritTest = Get-ChildItem Cert:\LocalMachine\My -ExpiringInDays 30
$certWarnTest = Get-ChildItem Cert:\LocalMachine\My -ExpiringInDays 60

If ($certCritTest -ne $null) {
    Write-Host -ForegroundColor Red 'Cert expiring within 30 days'
    exit $returnStateCritical 
    }
elseif ($certWarnTest -ne $null) {
    Write-Host -ForegroundColor Red 'Cert expiring within 60 days.'
    exit $returnStateWarning
    }
else {
    Write-Host -ForegroundColor Green 'Certs OK'
    exit $returnStateOK
}
