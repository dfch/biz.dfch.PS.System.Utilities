Function ConvertFrom-CmdletHelp {
<#
.SYNOPSIS

Converts the inline help of a Cmdlet to a Markdown compatible output.


.DESCRIPTION

Converts the inline help of a Cmdlet to a Markdown compatible output.

With this Cmdlet you can publish the inline help of your Cmdlets to markdown 
compatible repositories or wikis like Github, Bitbucket etc.


.EXAMPLE

ConvertFrom-CmdletHelp Get-Help -As GridView

This will convert the inline help of the 'Get-Help' Cmdlet to markdown and 
display it in a GridView that will be opened in a separate window.


.EXAMPLE

ConvertFrom-CmdletHelp Get-Help

This will convert the inline help of the 'Get-Help' Cmdlet to markdown and 
display the output on the console.


.EXAMPLE

ConvertFrom-CmdletHelp Get-Help, Get-Command -As file

This will convert the inline help of the 'Get-Help' and 'Get-Command' to 
markdown and write it to a file named 'Cmdlet.md' in the current directory.


.EXAMPLE

ConvertFrom-CmdletHelp Get-Help, Get-Command -As file -Path C:\data

This will convert the inline help of the 'Get-Help' and 'Get-Command' to 
markdown and write it to a file named 'Cmdlet.md' in 'C:\data'.


.LINK

Online Version http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-CmdletHelp/


.NOTES

See module manifest for required software versions and dependencies at: http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


#>

[CmdletBinding(
	SupportsShouldProcess = $true
	,
	ConfirmImpact = 'Low'
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-CmdletHelp/'
)]

PARAM 
(
	[ValidateScript( { Get-Command($_); } )]
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'command')]
	[ValidateNotNullOrEmpty()]
	[Alias("CommandName")]
	$InputObject = $MyInvocation.MyCommand.Name
	,
	[ValidateScript( { Get-Module -ListAvailable | sls $_; } )]
	[Parameter(Mandatory = $true, ParameterSetName = 'module')]
	[ValidateNotNullOrEmpty()]
	$ModuleName
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'markdown', 'gridview', 'file')]
	[Parameter(Mandatory = $false)]
	[Alias("ReturnFormat")]
	[string] $As = 'default'
	,
	[ValidateScript( { Test-Path -Path $_ -PathType Container; } )]
	[Parameter(Mandatory = $false)]
	[string] $Path = $PWD
)

BEGIN
{
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;
	
	[string] $fn = $MyInvocation.MyCommand.Name;
	
	if($As -eq 'file' -And [string]::IsNullOrEmpty($Path))
	{
		$e = New-CustomErrorRecord -m ("You must supply a 'Path' name when using 'file' as return format. Aborting ...") -cat InvalidArgument -o $null;
		Log-Error $fn $e.Exception.Message;
		$PSCmdlet.ThrowTerminatingError($e);
	}
	if($As -ne 'file' -And $PSBoundParameters.ContainsKey('Path'))
	{
		Write-Warning ("'Path' parameter will be ignored when return format is not 'file'.")
	}
	
	if($PSCmdlet.ParameterSetName -eq 'module')
	{
		$InputObject = Get-Command -Module $ModuleName;
	}
}
PROCESS
{
	foreach($Object in $InputObject)
	{
		if($PSCmdlet.ShouldProcess($Object))
		{
			$helpFormatted = @();
			foreach($line in ((help $Object -Full))) 
			{ 
				if( ![string]::IsNullOrWhiteSpace($line) -and $line -ceq $line.ToUpper() ) 
				{
					$line = "{0}`r`n" -f $line; 
				}
				if($line -match '\-+\ (\w+)\ (\d+)\ \-+') 
				{
					$line = "{0}{1}`r`n" -f $Matches[1], $Matches[2]; 
				}
				$helpFormatted += $line; 
			}

			$r = $helpFormatted;
			switch($As) 
			{
				'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
				'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
				'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
				'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
				'gridview' { $OutputParameter = $null; $r | Out-GridView -Title $Object; }
				'file' { $OutputParameter = $null; $r | Out-File (Join-Path -Path $Path -ChildPath ("{0}.md" -f $Object)) -Encoding Default; }
				Default { $OutputParameter = $r; }
			}
			$fReturn = $true;
			$OutputParameter
		}
	}
}
END
{
}
} # function
if($MyInvocation.ScriptName) { Export-ModuleMember -Function ConvertFrom-CmdletHelp; }

<#
2014-11-24; rrink; ADD: input validation of command names
2014-11-24; rrink; ADD: SupportsShouldProcess/ConfirmImpact
2014-11-24; rrink; ADD: file output return format
2014-11-24; rrink; ADD: pipeline input for multiple commands
2014-11-24; rrink; ADD: examples and inline help
2014-11-12; rrink; ADD: handling of EXAMPLE sections
2014-11-10; rrink; ADD: ConvertFrom-CmdletHelp
#>

# SIG # Begin signature block
# MIILewYJKoZIhvcNAQcCoIILbDCCC2gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU87HOn2QIn5ESYCrglLeLbSCs
# IjGgggjdMIIEKDCCAxCgAwIBAgILBAAAAAABL07hNVwwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0xOTA0MTMxMDAwMDBaMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWdu
# aW5nIENBIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyTxTn
# EL7XJnKrNpfvU79ChF5Y0Yoo/ENGb34oRFALdV0A1zwKRJ4gaqT3RUo3YKNuPxL6
# bfq2RsNqo7gMJygCVyjRUPdhOVW4w+ElhlI8vwUd17Oa+JokMUnVoqni05GrPjxz
# 7/Yp8cg10DB7f06SpQaPh+LO9cFjZqwYaSrBXrta6G6V/zuAYp2Zx8cvZtX9YhqC
# VVrG+kB3jskwPBvw8jW4bFmc/enWyrRAHvcEytFnqXTjpQhU2YM1O46MIwx1tt6G
# Sp4aPgpQSTic0qiQv5j6yIwrJxF+KvvO3qmuOJMi+qbs+1xhdsNE1swMfi9tBoCi
# dEC7tx/0O9dzVB/zAgMBAAGjgfowgfcwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFAhu2Lacir/tPtfDdF3MgB+oL1B6MEcGA1Ud
# IARAMD4wPAYEVR0gADA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxz
# aWduLmNvbS9yZXBvc2l0b3J5LzAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24ubmV0L3Jvb3QuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8G
# A1UdIwQYMBaAFGB7ZhpFDZfKiVAvfQTNNKj//P1LMA0GCSqGSIb3DQEBBQUAA4IB
# AQAiXMXdPfQLcNjj9efFjgkBu7GWNlxaB63HqERJUSV6rg2kGTuSnM+5Qia7O2yX
# 58fOEW1okdqNbfFTTVQ4jGHzyIJ2ab6BMgsxw2zJniAKWC/wSP5+SAeq10NYlHNU
# BDGpeA07jLBwwT1+170vKsPi9Y8MkNxrpci+aF5dbfh40r5JlR4VeAiR+zTIvoSt
# vODG3Rjb88rwe8IUPBi4A7qVPiEeP2Bpen9qA56NSvnwKCwwhF7sJnJCsW3LZMMS
# jNaES2dBfLEDF3gJ462otpYtpH6AA0+I98FrWkYVzSwZi9hwnOUtSYhgcqikGVJw
# Q17a1kYDsGgOJO9K9gslJO8kMIIErTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsr
# p6UyMA0GCSqGSIb3DQEBBQUAMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
# YWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWduaW5nIENB
# IC0gRzIwHhcNMTIwNjA4MDcyNDExWhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQG
# EwJERTEbMBkGA1UECBMSU2NobGVzd2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHpl
# aG9lMR0wGwYDVQQKDBRkLWZlbnMgR21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1m
# ZW5zIEdtYkggJiBDby4gS0cwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDTG4okWyOURuYYwTbGGokj+lvBgo0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHp
# Q8/QEMs87aalzHz2wtYN1dUIBUaedV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/p
# xu7yOwkAwn/iR+FWbfAyFoCThJYk9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9s
# ypQfrEToe5kBWkDYfid7U0rUkH/mbff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7
# D2f2hy9zTcdgzKVSPw41WTsQtB3i05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHIt
# N6zHpUAYxWwoyWLOcWcS69InAgMBAAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAG
# CCsGAQUFBzAChjRodHRwOi8vc2VjdXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9n
# c2NvZGVzaWduZzIuY3J0MB0GA1UdDgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAf
# BgNVHSMEGDAWgBQIbti2nIq/7T7Xw3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOC
# AQEAB3ZotjKh87o7xxzmXjgiYxHl+L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVg
# BHZAXqPKnlmAMAWj0+Tm5yATKvV682HlCQi+nZjG3tIhuTUbLdu35bss50U44zND
# qr+4wEPwzuFMUnYF2hFbYzxZMEAXVlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYV
# z3RhD4VdDPmMFv0P9iQ+npC1pmNLmCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7
# LbWSzZXedam6DMG0nR1Xcx0qy9wYnq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0S
# CjyVwk92xgNxYFwITJuNQIto4zGCAggwggIEAgEBMGcwUTELMAkGA1UEBhMCQkUx
# GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24g
# Q29kZVNpZ25pbmcgQ0EgLSBHMgISESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBSSHJQsOrKLGp5iePBG54uIGpQgHzANBgkqhkiG9w0BAQEFAASCAQAK
# dSmsTTPBYHTu1+X/ztVJjbrIqV2z/Ha28iZBgqM2efC+O4QMowXNOM+GlCdEB1oj
# c0Bbt7wHSixqy01rg1Q/cZqc+Q6R1zzD5PhAAIp0z8oxKIJdISbpsGdMMcVxgSK/
# AK5pma+P3sm0mpRjqWamb2O31stQJIHUCnO0MGh6PcREaclMByNO/GtIVWrwMMXg
# RFQOI/UHZ00U+YizGcApCFZ73c1RDmkmsz/yt9uwlSX5flbdZQatX9fY8SMHsN1v
# nOs0tbR8RJ14FJaOzvji5uY5ZzkqQzHVMjE+b2HtAHMckUcgLYHKkjf9SjHGg/76
# 81GU0FgwohZU1qpwDyOo
# SIG # End signature block
