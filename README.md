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

$CertFriendlyName = "E2016 Certificate CanadaSam"

$RequestFilePath = "C:\temp\E2016Cert_$(Get-Date -Format dddMMyyyy_HHmmss).req"

# Populate the below accordingly
# C=<CountryOrRegion>,S=<StateOrProvince>,L=<LocalityOrCity>,O=<Organization>,OU=<Department>]

# Country or Region
$SC = "ca"
# State or Province
$SS = "Ontario"
# Locality or City
$SL = "Ottawa"
# Organization
$SO = "Canada Sam"
#Department
$SOU = "IT Department"
# Subject FQDN (must be repeated in the SAN aka HereString Domain Names
$SCN = "mail.canadasam.ca"

# Put all your domains in this string (1 per line, no indent)
$HereStringDomainNames = @"
mail.canadasam.ca
autodiscover.canadasam.ca
"@
```

... and then just run the script.

-> if you leave ```[bool]$ExecuteCommand = $false```, the script will just print the ```New-ExchangeCertificate``` powershell command with all the values you specified on the customization part:

![image](https://user-images.githubusercontent.com/33433229/126735478-916b9b6d-868b-427a-bd44-d00af802fe3d.png)

-> if you want to run the new cert request, change ```[bool]$ExecuteCommand = $false``` to ```[bool]$ExecuteCommand = $true```

![image](https://user-images.githubusercontent.com/33433229/126735538-c9704310-5f48-45a4-8fdf-908c482286ff.png)

# After - Import Certificate, enable Exchange services (SMTP, IIS, ...)

## Complete request (EAC) or Import Certificate (PowerShell)

Once the certificate is received from the CA, you will notice a "Complete" certificate request menu in EAC/EMC/ECP for a pending certificate request :

![image](https://user-images.githubusercontent.com/33433229/126807911-fbea32c2-dbee-4909-b8e9-16e39db684a7.png)

when you click on it, it will ask you for a file UNC path (if the machine is local you can use ```\\localhost\c$\certificatefolderlocation\file.p7b```):

![image](https://user-images.githubusercontent.com/33433229/126808007-bbadbcf7-624c-4880-a9e6-b047c7638501.png)

and under the hood, that menu will trigger the following command:

```powershell
Import-ExchangeCertificate -PrivateKeyExportable "True" -FileName "\\localhost\c$\certificates\Cert_File_Received_From_CA.p7b" -Server "Server.fqdn" 
```

## Enable Exchange services (SMTP, IIS, POP, IMAP) on that cert

Then you enable the Exchange services on that new certificate so that it will be used with clients to establish secure SSL connection, on the EAC you need to open the new certificate properties and access the "Services" menu:

![image](https://user-images.githubusercontent.com/33433229/126808165-ae691a1d-da88-49d7-a75e-f3d2549ef3fc.png)

That will trigger the following Powershell Command line in the background (you will have a different certificate Identity, based on the server fqdn and the certificate thumbprint):

```powershell
Enable-ExchangeCertificate -Services "IMAP, POP, IIS, SMTP" -Identity "Myserver.fqdn\17BE570EFE20836063EE1771C0D18482FBB03846" -Force "True" 
```
