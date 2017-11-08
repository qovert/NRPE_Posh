function Compare-GroupMembership {
    [CmdletBinding()]
    Param()
    # Verify AD cmdlets available, return critical state if not
    try {
        Import-Module -Name ActiveDirectory -Cmdlet 'get-adgroup','get-adgroupmember' 
    }
    catch {
        Write-Verbose 'ActiveDirectory Module not installed... exiting.'
        exit $returnstateCrit
    }
    
    # Environment variables
    $SIDFile = 'C:\Users\ditto\Desktop\sids'
    $testSID = 'C:\Users\ditto\Desktop\testsid'    
    $Groups = 'Administrators', 'Domain admins'

    # Return states for Nsclient
    $returnStateOK = 0
    $returnStateWarning = 1
    $returnstateCrit = 2
    
    if (Test-Path -Path $SIDFile) {
        Write-Verbose 'SID File Exists'
    }
    else {
        # If file doesn't exist, create it and exit with a warning
        Write-Verbose 'SID file does not exist... creating.'
        ForEach ($g in $Groups) {
            Get-ADGroup $g | Get-ADGroupMember |Select-Object sid |
                Format-Table -HideTableHeaders |Out-File $SIDFile -Append
        }
        exit $returnStateWarning
    }

    # Get previous SID file, generate new SID file, compare
    $oldSID = (Get-Content $SIDFile) | ForEach-Object {
        $_.Trim() -ne "" } |Sort-Object     

    # Create comparison file
    ForEach ($g in $Groups) {
        Get-ADGroup $g |Get-ADGroupMember |Select-Object sid | 
            Format-Table -HideTableHeaders |Out-File $testSID -Append
    }
    $newSID = (Get-Content $testSID) | ForEach-Object {
        $_.Trim() -ne "" } |Sort-Object

    $TestCase = Compare-Object -ReferenceObject $oldSID -DifferenceObject $newSID

    if ($TestCase) {
        Write-Verbose 'Changes have been detected in monitored groups'
        exit $returnstateCrit
    }
    else {
        Write-Verbose 'No changes detected'
        exit $returnStateOK
    }

}
