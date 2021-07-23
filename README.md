# Exchange-2016-and-2019-Generate-Certificate-Request-Custom-Script

This script is simply a wrapper around the ```New-ExchangeCertificate``` cmdlet, which is used to generate the Certificate Signing Request (CSR) that you will send to your CA to get a certificate for your Exchange servers. I just populates the variables for the following command line:

```powershell
New-ExchangeCertificate -FriendlyName $CertFriendlyName -GenerateRequest -KeySize 2048 -SubjectName $SubjectName -DomainName $DomainNames -PrivateKeyExportable $true -RequestFile $RequestFilePath -ErrorAction Stop
```

This script generates the New-ExchangeCertificate command line with correct subject format, as well as domain names (SANs). You can choose to execute the command from the script ($ExecuteCommand = $true), or just paste the New-ExchangeCertificate command line for manual run (copy/paste) and/or documentation ($ExecuteCommand = $false).

> **NOTE**: the script puts the command line in the clipboard - just use CTRL + V to paste it anywhere after running the script

# Usage

Set the values at the beginning of the script:

```powershell
###################################################################
# Customization
###################################################################

#NOTE: set the below to "$true" to generate the certificate request
# if set to $False, it will just print the command on screen
# for documentation, or manual execution using Copy/Paste on a
# Exchange Management Shell session
[bool]$ExecuteCommand = $false

$CertFriendlyName = "E2016 Certificate"

$RequestFilePath = "C:\temp\E2016Cert_$(Get-Date -Format dddMMyyyy_HHmmss).req"

$SC = "ca"
$SS = "Ontario"
$SL = "Ottawa"
$SO = "Canada Sam"
$SOU = "IT Department"
$SCN = "mail.canadasam.ca"

$HereStringDomainNames = @"
mail.canadasam.ca
autodiscover.canadasam.ca
"@
```

... and then just run the script.

-> if you want to run the new cert request, change ```[bool]$ExecuteCommand = $false``` to ```[bool]$ExecuteCommand = $true```

![image](https://user-images.githubusercontent.com/33433229/126735538-c9704310-5f48-45a4-8fdf-908c482286ff.png)


-> if you leave ```[bool]$ExecuteCommand = $false```, the script will just print the ```New-ExchangeCertificate``` powershell command:

![image](https://user-images.githubusercontent.com/33433229/126735478-916b9b6d-868b-427a-bd44-d00af802fe3d.png)

# After - Import Certificate

## Complete request (EAC) or Import Certificate (PowerShell)

Once the certificate is received from the CA, the "Complete" certificate request menu in EAC/EMC/ECP for a pending certificate request will ask you for a file UNC path (if the machine is local you can use ```\\localhost\c$\certificatefolderlocation\file.p7b```), and it will call the following command:

```powershell
Import-ExchangeCertificate -PrivateKeyExportable "True" -FileName "\\localhost\c$\certificates\mail_canadasam_ca.p7b" -Server "E2016-01.CanadaDrey.ca" 
```

## Enable Exchange services (SMTP, IIS, POP, IMAP) on that cert

Then you enable the Exchange services on that new certificate so that it will be used with clients to establish secure SSL connection, on the EAC you need to open the new certificate properties and access the "Services" menu:

![image](https://user-images.githubusercontent.com/33433229/126806829-aa0c4080-0060-42c9-9a7f-236bb96a1cf5.png)

That will trigger the following Powershell Command line in the background (you will have a different certificate Identity, based on the server fqdn and the certificate thumbprint):

```powershell
Enable-ExchangeCertificate -Services "IMAP, POP, IIS, SMTP" -Identity "Myserver.fqdn\17BE570EFE20836063EE1771C0D18482FBB03846" -Force "True" 
```
