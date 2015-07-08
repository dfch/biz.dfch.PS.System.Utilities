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
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9y2hzp/51/PKQgR312RnLQ2U
# mlWgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSECDoOogZJ6Apj
# auZD7hvCBKtvnjANBgkqhkiG9w0BAQEFAASCAQBAO3DrqZdcIdxjlc1QfO9PQg03
# 3lV9lLKYMUHL2JJYWDwwjp1+KFloYD2MuGpZDmJjr2WEQITohkqMDc/n5u/Yao4R
# TW3VBu6GxZwvr2NuzVXUtcZVMpztPJB165EWmFeh997WHT/odnNt9YnOtpBLLmTH
# 62bzI74cSGUQG0T7WG6G3LEil9M6gfySrew7bw9cIBKcUrLraCrTsfLym+oxc1JF
# OTzqtGZvMzTgOvI5cplJlpi8R+NhEfKuhW92vQO6QnQ/pKIq+vTxF7pZqxvlan5o
# CYs644FKqiJls0+jRnMy2kNRu2zsiwtrOtOjyClElkn8KxJu3ZKC+H/P2EH/oYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MDcwODE1MTE1NlowIwYJKoZIhvcNAQkEMRYEFHLdCse59L6F1NHmjJkviJ5P9bJv
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQBai6yWcsTlaDdHsn8S
# 737FX8ZAsIj5lizZlnR5aHM81BCzIaCLeeX/4kH2wRd+GPDoea3sNyi3/+wJdpIz
# MfmC1b6RPTQrKj4CfzxX1NKP+EMaiWWErfPFZ5EwzXxE7fE+v5zLDXnrgP7j8tcO
# xXcIT8raVdDPZCgr8pEHzTYjhyjYVOKcxxoWVacTLC8Vr1j3QhPLYINlQ8avs1QZ
# gsC6BaqBmUu2+FTj4JPBaZYo2DxqTi3ye+dhFym9d2MmpN3OVZsXSLVZeMEsXad3
# O5JDXVxJj6JXf+RHuCp8jOPQjSSh1QwutMCCouW7wE61qQyZgVfJB2ffqVOje9a2
# /F2x
# SIG # End signature block
