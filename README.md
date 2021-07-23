# Exchange-2016-and-2019-Generate-Certificate-Request-Custom-Script

This script is simply a wrapper around the ```New-ExchangeCertificate``` cmdlet, which is used to generate the Certificate Signing Request (CSR) that you will send to your CA to get a certificate for your Exchange servers. I just populates the variables for the following command line:

```powershell
New-ExchangeCertificate -FriendlyName $CertFriendlyName -GenerateRequest -KeySize 2048 -SubjectName $SubjectName -DomainName $DomainNames -PrivateKeyExportable $true -RequestFile $RequestFilePath -ErrorAction Stop
```

This script generates the New-ExchangeCertificate command line with correct subject format, as well as domain names (SANs). You can choose to execute the command from the script ($ExecuteCommand = $true), or just dump the New-ExchangeCertificate command line for manual run (copy/paste) and/or documentation ($ExecuteCommand = $false).

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

$CertFriendlyName = "E2016 Certificate CanadaSam Exp. Aug. 2021"

$RequestFilePath = "C:\temp\E2016Cert21JUL2021_$(Get-Date -Format dddMMyyyy_HHmmss).req"

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
