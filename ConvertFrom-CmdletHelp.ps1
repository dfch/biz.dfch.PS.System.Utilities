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
	,
	[Parameter(Mandatory = $false, ParameterSetName = 'module')]
	[Alias("Exclude")]
	[switch] $ExcludeDefaultCommandPrefix = $true
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
		if($ExcludeDefaultCommandPrefix)
		{
			foreach($PSModulePath in $ENV:PSModulePath.Split(';')) 
			{ 
				$PSModulePathFull = Join-Path -Path $PSModulePath -ChildPath $ModuleName;
				if( !(Test-Path -Path ($PSModulePathFull)) ) 
				{ 
					continue;
				}
				$Manifest = Join-Path -Path $PSModulePathFull -ChildPath ('{0}.psd1' -f $ModuleName);
				if( Test-Path -Path ($Manifest) ) 
				{ 
					try
					{
						$DefaultCommandPrefix =  ( (Get-Content (Get-Item $Manifest) -Raw) | iex ).DefaultCommandPrefix;
					}
					catch
					{
						# N/A
					}
					if(!$DefaultCommandPrefix)
					{
						Write-Warning ("No 'DefaultCommandPrefix' found in Manifest '{0}'." -f $Manifest);
					}
					break;
				}
			}
			$PSModulePathFull = $null;
			$Manifest = $null;
		}
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
				'file' 
				{ 
					if(0 -ge $r.Count)
					{
						Write-Warning ("Cmdlet '{0}' has no content [{1}]. Skipping ..." -f $Object.Name, $r.Count);
					}
					else 
					{
						$OutputParameter = $null; 
						if($ExcludeDefaultCommandPrefix)
						{
							$r | Out-File (Join-Path -Path $Path -ChildPath ("{0}.md" -f $Object.Name.Replace($DefaultCommandPrefix, $null))) -Encoding Default; 
						}
						else
						{
							$r | Out-File (Join-Path -Path $Path -ChildPath ("{0}.md" -f $Object.Name)) -Encoding Default; 
						}
					}
				}
				Default { $OutputParameter = $r; }
			}
			$fReturn = $true;
			$OutputParameter
		}
	}
}

END
{
	# N/A
}

} # function
if($MyInvocation.ScriptName) { Export-ModuleMember -Function ConvertFrom-CmdletHelp; }

<#
2014-11-25; rrink; ADD: ExcludeDefaultCommandPrefix parameter
2014-11-24; rrink; ADD: input validation of command names
2014-11-24; rrink; ADD: SupportsShouldProcess/ConfirmImpact
2014-11-24; rrink; ADD: file output return format
2014-11-24; rrink; ADD: pipeline input for multiple commands
2014-11-24; rrink; ADD: examples and inline help
2014-11-12; rrink; ADD: handling of EXAMPLE sections
2014-11-10; rrink; ADD: ConvertFrom-CmdletHelp
#>

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9y2hzp/51/PKQgR312RnLQ2U
# mlWgghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCgwggMQoAMCAQICCwQAAAAAAS9O4TVcMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNV
# BAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290
# IENBMRswGQYDVQQDExJHbG9iYWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAw
# WhcNMTkwNDEzMTAwMDAwWjBRMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEnMCUGA1UEAxMeR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAt
# IEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsk8U5xC+1yZyqzaX
# 71O/QoReWNGKKPxDRm9+KERQC3VdANc8CkSeIGqk90VKN2Cjbj8S+m36tkbDaqO4
# DCcoAlco0VD3YTlVuMPhJYZSPL8FHdezmviaJDFJ1aKp4tORqz48c+/2KfHINdAw
# e39OkqUGj4fizvXBY2asGGkqwV67Wuhulf87gGKdmcfHL2bV/WIaglVaxvpAd47J
# MDwb8PI1uGxZnP3p1sq0QB73BMrRZ6l046UIVNmDNTuOjCMMdbbehkqeGj4KUEk4
# nNKokL+Y+siMKycRfir7zt6prjiTIvqm7PtcYXbDRNbMDH4vbQaAonRAu7cf9DvX
# c1Qf8wIDAQABo4H6MIH3MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdDgQWBBQIbti2nIq/7T7Xw3RdzIAfqC9QejBHBgNVHSAEQDA+MDwG
# BFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20v
# cmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2NybC5nbG9iYWxz
# aWduLm5ldC9yb290LmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAfBgNVHSMEGDAW
# gBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEAIlzF3T30
# C3DY4/XnxY4JAbuxljZcWgetx6hESVEleq4NpBk7kpzPuUImuztsl+fHzhFtaJHa
# jW3xU01UOIxh88iCdmm+gTILMcNsyZ4gClgv8Ej+fkgHqtdDWJRzVAQxqXgNO4yw
# cME9fte9LyrD4vWPDJDca6XIvmheXW34eNK+SZUeFXgIkfs0yL6Erbzgxt0Y2/PK
# 8HvCFDwYuAO6lT4hHj9gaXp/agOejUr58CgsMIRe7CZyQrFty2TDEozWhEtnQXyx
# Axd4CeOtqLaWLaR+gANPiPfBa1pGFc0sGYvYcJzlLUmIYHKopBlScENe2tZGA7Bo
# DiTvSvYLJSTvJDCCBJ8wggOHoAMCAQICEhEhQFwfDtJYiCvlTYaGuhHqRTANBgkq
# hkiG9w0BAQUFADBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBu
# di1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjAe
# Fw0xMzA4MjMwMDAwMDBaFw0yNDA5MjMwMDAwMDBaMGAxCzAJBgNVBAYTAlNHMR8w
# HQYDVQQKExZHTU8gR2xvYmFsU2lnbiBQdGUgTHRkMTAwLgYDVQQDEydHbG9iYWxT
# aWduIFRTQSBmb3IgTVMgQXV0aGVudGljb2RlIC0gRzEwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCwF66i07YEMFYeWA+x7VWk1lTL2PZzOuxdXqsl/Tal
# +oTDYUDFRrVZUjtCoi5fE2IQqVvmc9aSJbF9I+MGs4c6DkPw1wCJU6IRMVIobl1A
# cjzyCXenSZKX1GyQoHan/bjcs53yB2AsT1iYAGvTFVTg+t3/gCxfGKaY/9Sr7KFF
# WbIub2Jd4NkZrItXnKgmK9kXpRDSRwgacCwzi39ogCq1oV1r3Y0CAikDqnw3u7sp
# Tj1Tk7Om+o/SWJMVTLktq4CjoyX7r/cIZLB6RA9cENdfYTeqTmvT0lMlnYJz+iz5
# crCpGTkqUPqp0Dw6yuhb7/VfUfT5CtmXNd5qheYjBEKvAgMBAAGjggFfMIIBWzAO
# BgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAyAR4wNDAyBggrBgEF
# BQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYD
# VR0TBAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDBCBgNVHR8EOzA5MDegNaAz
# hjFodHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzdGltZXN0YW1waW5nZzIu
# Y3JsMFQGCCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5n
# bG9iYWxzaWduLmNvbS9jYWNlcnQvZ3N0aW1lc3RhbXBpbmdnMi5jcnQwHQYDVR0O
# BBYEFNSihEo4Whh/uk8wUL2d1XqH1gn3MB8GA1UdIwQYMBaAFEbYPv/c477/g+b0
# hZuw3WrWFKnBMA0GCSqGSIb3DQEBBQUAA4IBAQACMRQuWFdkQYXorxJ1PIgcw17s
# LOmhPPW6qlMdudEpY9xDZ4bUOdrexsn/vkWF9KTXwVHqGO5AWF7me8yiQSkTOMjq
# IRaczpCmLvumytmU30Ad+QIYK772XU+f/5pI28UFCcqAzqD53EvDI+YDj7S0r1tx
# KWGRGBprevL9DdHNfV6Y67pwXuX06kPeNT3FFIGK2z4QXrty+qGgk6sDHMFlPJET
# iwRdK8S5FhvMVcUM6KvnQ8mygyilUxNHqzlkuRzqNDCxdgCVIfHUPaj9oAAy126Y
# PKacOwuDvsu4uyomjFm4ua6vJqziNKLcIQ2BCzgT90Wj49vErKFtG7flYVzXMIIE
# rTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsrp6UyMA0GCSqGSIb3DQEBBQUAMFEx
# CzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQD
# Ex5HbG9iYWxTaWduIENvZGVTaWduaW5nIENBIC0gRzIwHhcNMTIwNjA4MDcyNDEx
# WhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQGEwJERTEbMBkGA1UECBMSU2NobGVz
# d2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHplaG9lMR0wGwYDVQQKDBRkLWZlbnMg
# R21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1mZW5zIEdtYkggJiBDby4gS0cwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTG4okWyOURuYYwTbGGokj+lvB
# go0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHpQ8/QEMs87aalzHz2wtYN1dUIBUae
# dV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/pxu7yOwkAwn/iR+FWbfAyFoCThJYk
# 9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9sypQfrEToe5kBWkDYfid7U0rUkH/m
# bff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7D2f2hy9zTcdgzKVSPw41WTsQtB3i
# 05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHItN6zHpUAYxWwoyWLOcWcS69InAgMB
# AAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4AwTAYDVR0gBEUwQzBBBgkrBgEEAaAy
# ATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFsc2lnbi5jb20vcmVw
# b3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzA+BgNVHR8E
# NzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2JhbHNpZ24uY29tL2dzL2dzY29kZXNp
# Z25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAGCCsGAQUFBzAChjRodHRwOi8vc2Vj
# dXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9nc2NvZGVzaWduZzIuY3J0MB0GA1Ud
# DgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAfBgNVHSMEGDAWgBQIbti2nIq/7T7X
# w3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOCAQEAB3ZotjKh87o7xxzmXjgiYxHl
# +L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVgBHZAXqPKnlmAMAWj0+Tm5yATKvV6
# 82HlCQi+nZjG3tIhuTUbLdu35bss50U44zNDqr+4wEPwzuFMUnYF2hFbYzxZMEAX
# Vlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYVz3RhD4VdDPmMFv0P9iQ+npC1pmNL
# mCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7LbWSzZXedam6DMG0nR1Xcx0qy9wY
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zGC
# BK4wggSqAgEBMGcwUTELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBHMgIS
# ESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQow
# CKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcC
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSECDoOogZJ6ApjauZD
# 7hvCBKtvnjANBgkqhkiG9w0BAQEFAASCAQCaKboeOkf9yQq/KVHislJd1hYsSxQH
# lAaXb8c9AbFigxsKHxHTj1oE5CL8ytUlOkBuIFLzoapaGOXi/IB2Hd10yGPFBCsS
# WJFLKJLOAtUVxs/Lqnd5GnXYL/iTNu0/nuiODlsdE9XMK0p++8D6rh2gQEQgsTk0
# t6QgGOchFqqfvwTOgH4PcJe8S7KeGOZUu+yfr7CwuZ7OW+7ChNxrDLCe4ArF0z4w
# Bk+JPcmP3on6HoqT0w0tIL8pLT7GtAzCuUbrO9mJi2PZdnLK2OvPEmGMwzxzWwIQ
# GLndzPpu0V1ST/WUBA+o897RcQcwjYZtszWbfsvmWLJ16f4TQgBNvDY7oYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MTEy
# NTE2MjU1MlowIwYJKoZIhvcNAQkEMRYEFPKRgGULxHT7t/HsYN71izSQMYHrMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQCs4ZMf6C9IysjVmq7SaREZ
# qhmDsfsWGox9BCflcFvEOE0Dh0MHBVH3w1Qdd2pKkdHNx/Yr5o93EHM80XSZSiUi
# Kcz1I+TujfjatQI/9POlG95ijQxVHhjHfakY3Cb71yBDDsICpOHjCbXpztcmGgTB
# AXZ3Jc4AryT614vdbUOSVFe1KGdeJTrFf0j7B/KNcF2t6FNlejbKTMX9siAaa6Qb
# MaiY6VIwxGYi/K0h2aemsb/hyMtpt/EWMxLymMRlLamnYA+waMnJoWJPE9nHIEIv
# KQ7KVS4abjZptV+AmNDR5YekZInavJwttPg4rA4KPuEffiuOPu/jcnp+AbxdLovN
# SIG # End signature block
