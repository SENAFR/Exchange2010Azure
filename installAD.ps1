
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


Configuration InstallAD {

    Import-DscResource -ModuleName xActiveDirectory, xNetworking, xPendingReboot, PSDesiredStateConfiguration, ComputerManagementDsc
    $pwd = ConvertTo-SecureString "Test12345!1" -AsPlainText -Force
    $creds = New-Object System.Management.Automation.PSCredential ("Administrator", $pwd)
    
    node $AllNodes.NodeName
    {
       
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndMonitor'            
            RebootNodeIfNeeded = $true           
        }
         xPendingReboot Reboot1 
        {  
            Name = ‘AfterSoftwareInstall’ 
        }
        Computer NewName
        {
            Name = 'DC01'
        } 

        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
        }
        ##xDnsServerAddress DnsServerAddress 
        ###{ 
          ##  Address        = '127.0.0.1' 
          #  InterfaceAlias = 'Ethernet2'
           # AddressFamily  = 'IPv4'
            #DependsOn = "[WindowsFeature]DNS"
       # }

        WindowsFeature RSAT
        {
            Ensure = "Present"
            Name = "RSAT"
        }

        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
        }  
        xADDomain build
        {
            DomainName                    = $Node.DomainName
            DomainAdministratorCredential = $creds
            SafemodeAdministratorPassword = $creds
            DomainMode                    = $Node.DFL
            ##DependsOn = "[WindowsFeature]AD-Domain-Services"
            
        }
       
       
}
        
   }

installad -configuration $configurationdata -outputpath .\installad ##creates the files
set-dsclocalconfigurationmanager -path .\installad
Start-DscConfiguration -Wait -Verbose -Path .\installad\ 
