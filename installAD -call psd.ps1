
##my own file made from lots of others i found. This is working but needs refinement.
## This needs to import and use computer management dsc to rename the server. Also needs to auto reboot after AD isntall. DNS needs to be configured preoperly 

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name xActiveDirectory,xnetworking,xpendingreboot,ComputerManagementDsc

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = 'localhost'
            DFL                         = 'Win2012R2'
            DomainName                  = 'kptestlab.com'
            PSDscAllowPlainTextPassword = $true
        }
    )
}

.\installAD.psd


installad -configuration $configurationdata -outputpath .\installad ##creates the files
#set-dsclocalconfigurationmanager -path .\installad
#Start-DscConfiguration -Wait -Verbose -Path .\installad\ 
