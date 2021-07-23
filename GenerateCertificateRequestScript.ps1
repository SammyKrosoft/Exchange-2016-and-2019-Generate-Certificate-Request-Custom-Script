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

###################################################################
# Functions
###################################################################

  
function Global:Convert-HString {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)] [String]$HString
        )

    <#NOTE: This function is from Ben Wilkinson - https://gallery.technet.microsoft.com/scriptcenter/917c2357-2911-4c79-bd06-ab95714de2d4#>

    Begin 
    {Write-Verbose "Converting Here-String to Array"}
    Process 
    {
        $HString -split "`n" | ForEach-Object {
            $Item = $_.trim()
            #NOTE: below is to enable the use of hashtag to comment aka ignore #lines in your txt file...
            if ($Item -notmatch "#")
            {$Item}    
        }
    }#Process
    End 
    {
        # Nothing to do here.
    }
}#Convert-HString


###################################################################
# Building strings from customization
###################################################################


$SubjectName = "c=$SC, s=$SS, l=$SL, o=$SO, ou=$SOU, cn=$SCN"
$DomainNames = (Convert-HString $HereStringDomainNames) -join ","


###################################################################
# Building the New-ExchangeCertificate command
###################################################################
$Command = "New-ExchangeCertificate -FriendlyName """ + $CertFriendlyName + """ -GenerateRequest -KeySize 2048 -SubjectName """ + $SubjectName + """ -DomainName $DomainNames -PrivateKeyExportable `$true -RequestFile $RequestFilePath  -ErrorAction Stop"

###################################################################
# Printing the command to execute (for info or documentation)
###################################################################
write-host $command -ForegroundColor green

###################################################################
# Executing the command if we set the variable $ExecuteCommand 
# on the Customization section to $True
###################################################################
If ($ExecuteCommand){
    Try{
        invoke-expression $Command
        Write-Host "CSR file written ->> $RequestFilePath" -ForegroundColor Yellow -BackgroundColor Blue
    }
    Catch {
        Write-Host "Failed to run New-ExchangeCertificate" -ForegroundColor DarkRed -BackgroundColor Yellow
        Write-Host "Reason:" -NoNewline -ForegroundColor DarkRed -BackgroundColor Yellow
        Write-Host " $($_.Exception.Message)" -ForegroundColor Red
    }
    
}
