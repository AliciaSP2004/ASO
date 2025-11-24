#
#Script de Windows PowerShell para implementación de AD DS 
#
Import-Module ADDSDeployment  
Install-ADDSForest  
-CreateDnsDelegation:$false  
-DatabasePath "C:\WINDOWS\NTDS" 
-DomainMode "Win2025"  
-DomainName "asp.local"  
-DomainNetbiosName "ASP"  
-ForestMode "Win2025" -InstallDns:$true  
-LogPath "C:\WINDOWS\NTDS"  
-NoRebootOnCompletion:$false  
-SysvolPath "C:\WINDOWS\SYSVOL" `  
-Force:$true 