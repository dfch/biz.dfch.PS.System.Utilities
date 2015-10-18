function Test-CmdletDocumentation {
<#
.SYNOPSIS

Tests the documentation of a Cmdlet.


.DESCRIPTION

Tests the documentation of a Cmdlet.

This Cmdlet lets you test for the existence working of inline help and 
documentation of a Cmdlet or advanced function.


.EXAMPLE

Test-CmdletDocumentation Get-Command -All
Performs all tests on the Cmdlet "Get-Command".


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Test-CmdletDocumentation/



.NOTES

See module manifest for required software versions and dependencies at:
http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


#>

[CmdletBinding(
	SupportsShouldProcess = $true
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Test-CmdletDocumentation/'
	,
	DefaultParameterSetName = 'all'
)]
[OutputType([string])]

PARAM
(
	# One ore more Cmdlets to test
	[ValidateScript( { Get-Command($_); } )]
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
	$InputObject
	,
	# Performs all available tests on the specified Cmdlet
	[Parameter(Mandatory = $false, ParameterSetName = 'all')]
	[switch] $All = $true
	,
	# Tests if the Cmdlet has defined a '.SYNOPSIS' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Synopsis
	,
	# Tests if the Cmdlet has defined a '.DESCRIPTION' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Description
	,
	# Tests if the Cmdlet has defined a '.LINK' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[Alias("Related")]
	[Alias("RelatedLinks")]
	[switch] $Link
	,
	# Tests if the Cmdlet has defined a '.NOTES' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Notes
	,
	# Tests if the Cmdlet has defined a '.INPUTS' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Inputs
	,
	# Tests if the Cmdlet has defined a '.OUTPUTS' section
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Outputs
	,
	# Tests if the Cmdlet has defined a 'HelpUri' attribute in 'CmdletBinding'
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $HelpUri
	,
	# Tests if the Cmdlet has defined a 'SupportsShouldProcess' attribute in 'CmdletBinding'
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $SupportsShouldProcess
	,
	# # Tests if the Cmdlet has defined a 'ConfirmImpact' attribute in 'CmdletBinding'
	# [ValidateSet('None', 'Low', 'Medium', 'High')]
	# [Parameter(Mandatory = $false, ParameterSetName = 'param')]
	# [string] $ConfirmImpact
	# ,
	# Tests if the Cmdlet has defined a 'DefaultParameterSetName' attribute in 'CmdletBinding'
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $DefaultParameterSetName
	,
	# Tests if the Cmdlet has defined at least the specified number of '.EXMAMPLE' sections
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Examples
	,
	# Specifies the minimum number of examples the Cmdlet should supply
	[Parameter(Mandatory = $false)]
	[int] $ExamplesMinimum = 1
	,
	# Tests if the Cmdlet defined a description for all its parameters
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Parameters
	,
	# Specifies the parameters to be excluded from the 'Parameters' check
	[Parameter(Mandatory = $false)]
	[string[]] $ParametersExclude = @("WhatIf", "Confirm", "Verbose")
	,
	# Tests if the Cmdlet defined a '.FUNCTIONALITY'
	[Parameter(Mandatory = $false, ParameterSetName = 'param')]
	[switch] $Functionality
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[Alias("ReturnFormat")]
	[string] $As = 'default'
)

BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	$OutputParameter = $null;
	Log-Debug -fn $fn -msg ("CALL. InputObject.Count: '{0}'" -f $InputObject.Count) -fac 1;
}
# BEGIN

PROCESS 
{
	foreach($Object in $InputObject) 
	{
		$fReturn = $false;
		$OutputParameter = $null;
		
		if(!$PSCmdlet.ShouldProcess( $Object ))
		{
			continue;
		}
		
		if($PSCmdlet.ParameterSetName -eq 'all')
		{
			$Synopsis = $true;
			$Description = $true;
			$Link = $true;
			$Notes = $true;
			$Inputs = $true;
			$Outputs = $true;
			$HelpUri = $true;
			$SupportsShouldProcess = $true;
			$DefaultParameterSetName = $true;
			$Examples = $true;
			$Parameters = $true;
			$Functionality = $true;
		}
		# Get command to work on
		$cmd = Get-Command $Object;
		$h = Get-Help $cmd;
		
		$r = @{};
		$r.Name = $cmd.Name;
		
		# Check for Synopsis
		if($Synopsis) 
		{
			if($h.Synopsis)
			{
				$r.Synopsis = $true;
			}
			else
			{
				$r.Synopsis = $false;
				$msg = "{0}: Testing for 'Synopsis' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for Description
		if($Description) 
		{
			if($h.Description)
			{
				$r.Description = $true;
			}
			else
			{
				$r.Description = $false;
				$msg = "{0}: Testing for 'Description' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for Link
		if($Link) 
		{
			if( $h.relatedLinks -And $h.relatedLinks.navigationLink )
			{
				$r.Link = $true;
			}
			else
			{
				$r.Link = $false;
				$msg = "{0}: Testing for '.LINK' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for NOTES
		if($Notes) 
		{
			if($h.alertSet)
			{
				$r.Notes = $true;
			}
			else
			{
				$r.Notes = $false;
				$msg = "{0}: Testing for '.NOTES' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for INPUTS
		if($Inputs) 
		{
			if($h.inputTypes)
			{
				$r.Inputs = $true;
			}
			else
			{
				$r.Inputs = $false;
				$msg = "{0}: Testing for '.INPUTS' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for OUTPUTS
		if($Outputs) 
		{
			if($h.returnValues)
			{
				$r.Outputs = $true;
			}
			else
			{
				$r.Outputs = $false;
				$msg = "{0}: Testing for '.OUTPUTS' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for HELPURI
		if($HelpUri) 
		{
			if($cmd.HelpUri)
			{
				$r.HelpUri = $true;
			}
			else
			{
				$r.HelpUri = $false;
				$msg = "{0}: Testing for 'HelpUri' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for SupportsShouldProcess
		if($SupportsShouldProcess) 
		{
			if($cmd.Parameters.ContainsKey('Confirm') -And $cmd.Parameters.ContainsKey('WhatIf'))
			{
				$r.SupportsShouldProcess = $true;
			}
			else
			{
				$r.SupportsShouldProcess = $false;
				$msg = "{0}: Testing for 'SupportsShouldProcess' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for DefaultParameterSetName
		if($DefaultParameterSetName) 
		{
			if($cmd.DefaultParameterSet)
			{
				$r.DefaultParameterSetName = $true;
			}
			else
			{
				$r.DefaultParameterSetName = $false;
				$msg = "{0}: Testing for 'DefaultParameterSetName' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for Examples
		if($Examples) 
		{
			if( $h.Examples -And $h.Examples.Example )
			{
				if( (1 -eq $ExamplesMinimum -And $h.Examples.Example) -Or ($h.Examples.Example -is [Array] -And ($ExamplesMinimum -le $h.Examples.Example.Count)) )
				{
					$r.Examples = $true;
				}
				if(1 -eq $Examples)
				{
					$r.Examples = $true;
				}
			}
			if(!$r.Examples)
			{
				$r.Examples = $false;
				$msg = "{0}: Testing for '.EXAMPLE' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for Parameters
		if($Parameters) 
		{
			if( $h.Parameters -And $h.Parameters.Parameter )
			{
				$params = @();
				foreach($p in $h.Parameters.Parameter)
				{
					if(!$p.Description -And ($ParametersExclude -notcontains $p.name) )
					{
						$params += $p.Name
					}
				}
				if(!$params)
				{
					$r.Parameters = $true;
				}
			}
			if(!$r.Parameters)
			{
				$r.Parameters = $params;
				$msg = "{0}: Testing for '.PARAMETER' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		# Check for Functionality
		if($Functionality) 
		{
			if($h.Functionality)
			{
				$r.Functionality = $true;
			}
			else
			{
				$r.Functionality = $false;
				$msg = "{0}: Testing for 'Functionality' FAILED." -f $cmd.Name;
				Log-Warn $fn $msg;
				Write-Verbose $msg;
			}
		}
		
		switch($As) 
		{
			'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
			'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
			'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
			'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
			Default { $OutputParameter = $r; }
		}
		$OutputParameter;
	}
	$fReturn = $true;
}
# PROCESS

END 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}
# END

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Test-CmdletDocumentation; } 

#
# Copyright 2014-2015 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYGP2dzhwD7gp53+BWtfqeeLi
# AgagghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSfqJQ/tdXs7C8Z
# Ei1Gk9LH/zO7NzANBgkqhkiG9w0BAQEFAASCAQCyp957TOlzPIB0z6gPChR6m8Ps
# 7j6Azl8pLP4CZ8ghda0c9Egfwc4SvppilfjHkM68JNk6/tbRNwPkMrrk85fUJs6t
# xysk6PaIkc69MFL+N7p8jKM12uPO6ekCtvTd1Lul94032eB1EfVK/AGRpebAWEAM
# V35GAZFB5HDPuYyQHvROd8FNKEoI8r52h299nz7kWVkA2ecVIbfCwluX+WJDPv7e
# xmEQEkxew5EZQ4qatoeoYB//F3syK5xeDEGhUtRq7RldIxQbvzWXUMy72XApMp7i
# pdeMsqwen1+g8gYPdmIjtaiWiO0h4YIRGoRU7ZQSsFCfnJhWhkUeybnE3WusoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTAxODExMDMyMFowIwYJKoZIhvcNAQkEMRYEFBqJUqHh6hDV5Rprj4/NPY79rqEC
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQAls9caJkmm5fDyTxJ3
# 1+8Rr3Ec7jpaDCvb42AFZN/LQA2e9Nt/zGsKC/CfZ7OLNV1Foppil/5zG4ZScWQP
# I+L6h1kYMJS3EX9wTI6g4WZsFNj+37xycTYQ8JwCGlXaxPmqTLa8tc8AEMNbLHaW
# JXhFQGbRaBEnP1XcjMY0peydPSHy0KejwstoCxsZ/PeXyK6CrMqbZjppXi2XgxHB
# L3QKkR/ZM81SCcPFruCmX9aE5fdAHkXfyOuDxl7AhdmpMoItrA2wKAH7I4G6Pvua
# npwiY7jGuRt8duisouBq5Im1IPm73MxwTOuUDx17lPlJIdQW42USN2BsuA62zC+4
# ilnR
# SIG # End signature block
