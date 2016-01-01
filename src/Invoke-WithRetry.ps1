Function Invoke-WithRetry {
<#
.SYNOPSIS
Invokes a given scriptblock and retries upon failure.

.DESCRIPTION
Invokes a given scriptblock and retries upon failure.

The specified scriptblock is executed via Invoke-Command. If the scriptblock 
throws an error the scriptblock will be executed again until it succeeds or 
the specified maximum number of attempts has been reached.
If the scriptblock succeeds its value is returned.

You can optionally pass parameters to the scriptblock.

.EXAMPLE
In this example we define a scriptblock that returns the current time to the 
caller.

This scriptblock is then executed via the 'Fixed' RetryStrategy. The returned 
value is then saved to the '$result' variable and written to the console.

PS > [scriptblock] $scriptblock = { 
	return [System.DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff');
}

PS > $result = $scriptblock | Invoke-WithRetry -RetryStrategy Fixed;
PS > $result
2016-01-01 22:48:48.849

.EXAMPLE
In this example we define a scriptblock that outputs a string and the current 
time. To simulate an error the scriptblock also throws an exception. 

This scriptblock is then executed via the 'Fixed' RetryStrategy as you can see 
from the time stamps.

PS > [scriptblock] $scriptblock = { 
	Write-Host ("arbitrary string {0}" -f [System.DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff'));
	throw 
}

PS > $scriptblock | Invoke-WithRetry -RetryStrategy Fixed;
arbitrary string 2016-01-01 22:43:04.147
arbitrary string 2016-01-01 22:43:04.375
arbitrary string 2016-01-01 22:43:04.596
arbitrary string 2016-01-01 22:43:04.804
arbitrary string 2016-01-01 22:43:05.017

.EXAMPLE
In this example we define a scriptblock that outputs a string and the current 
time. To simulate an error the scriptblock also throws an exception. 

This scriptblock is then executed via the 'Incremental' RetryStrategy as you can see 
from the time stamps.

PS > [scriptblock] $scriptblock = { 
	Write-Host ("arbitrary string {0}" -f [System.DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff'));
	throw 
}

PS > $scriptblock | Invoke-WithRetry -RetryStrategy Incremental -Step 2000 -MaxAttempts 3;
arbitrary string 2016-01-01 22:46:16.979
arbitrary string 2016-01-01 22:46:18.995
arbitrary string 2016-01-01 22:46:23.003

.EXAMPLE
In this example we define a scriptblock that accepts an input parameter and 
throws an assertion if the input is 1. The scriptblock itself will output an 
arbitrary string and the specified input.

In the example you see how the wait time between each interval doubles.

PS > [scriptblock] $scriptblock = { 
	PARAM
	(
		$count
	)
	Write-Host ("arbitrary string {0} {1}" -f $count, [System.DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss.fff')); 
	Contract-Assert ($count -ne 1)
}

PS > $scriptblock | Invoke-WithRetry -RetryStrategy Exponential -ArgumentList 1 -MaxAttempts 6;
arbitrary string 1 2016-01-01 22:42:39.394
WARNING: : Assertion failed: ($count -ne 1)
arbitrary string 1 2016-01-01 22:42:39.615
WARNING: : Assertion failed: ($count -ne 1)
arbitrary string 1 2016-01-01 22:42:40.032
WARNING: : Assertion failed: ($count -ne 1)
arbitrary string 1 2016-01-01 22:42:40.860
WARNING: : Assertion failed: ($count -ne 1)
arbitrary string 1 2016-01-01 22:42:42.482
WARNING: : Assertion failed: ($count -ne 1)
arbitrary string 1 2016-01-01 22:42:45.709
WARNING: : Assertion failed: ($count -ne 1)

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Invoke-WithRetry/

.NOTES
See module manifest for required software versions and dependencies at: http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/

#>
[CmdletBinding(
    SupportsShouldProcess = $true
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Invoke-WithRetry/'
)]
PARAM
(
	# Specifies the scriptblock to execute
	[ValidateNotNull()]
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
	[Alias('InputObject')]
	[scriptblock] $ScriptBlock
	,
	# Specifies optional arguments for the scriptblock
	[Parameter(Mandatory = $false, Position = 1)]
	[Object[]] $ArgumentList
	,
	# Specifies the total number of attempty to execute the scriptblock
	# Default is 5
	[ValidateRange(1,[int]::MaxValue)]
	[Parameter(Mandatory = $false)]
	[int] $MaxAttempts = 5
	,
	# Specifies the base wait time for retry operations in milliseconds
	# Default is 200
	[Parameter(Mandatory = $false)]
	[Alias('Step')]
	[int] $InitialWaitTimeInMilliseconds = 200
	,
	# Specifies the retry strategy
	# Default is exponential.
	[ValidateSet('Exponential', 'Fixed', 'Incremental')]
	[Parameter(Mandatory = $false)]
	[string] $RetryStrategy = 'Exponential'
	,
	# Specifies if the scriptblock should be defined as a new closure
	[Parameter(Mandatory = $false)]
	[switch] $NewClosure = $false
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. RetryStrategy: {0}; MaxAttempts: {1}. InitialWaitTimeInMilliseconds: {2}." -f $RetryStrategy, $MaxAttempts, $InitialWaitTimeInMilliseconds) -fac 1;
	
	if($NewClosure)
	{
		$ScriptBlock = $ScriptBlock.GetNewClosure();
	}
	
	$currentAttempt = 0;
	$currentWaitTimeMs = $InitialWaitTimeInMilliseconds;
	$fCompleted = $false;
}

Process 
{
	trap { Log-Exception $_; break; }

	$OutputParameter = $null;
	$fReturn = $false;

	do
	{
		$currentAttempt++;

		if($PSCmdlet.ShouldProcess(('{0}: {1}/{2} @{3}ms' -f $RetryStrategy, $currentAttempt, $MaxAttempts, $currentWaitTimeMs)))
		{
			Log-Debug $fn ("Executing scriptblock ... [{0}/{1}]" -f $currentAttempt, $MaxAttempts);
			try
			{
				if($ArgumentList)
				{
					$result = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList;
				}
				else
				{
					$result = Invoke-Command -ScriptBlock $ScriptBlock;
				}
				Log-Info $fn ("Executing scriptblock COMPLETED. [{0}/{1}]" -f $currentAttempt, $MaxAttempts);
				$fReturn = $true;
				break;
			}
			catch
			{
				Log-Exception $_;
				if($currentAttempt -lt $MaxAttempts)
				{
					Log-Warning $fn ("Executing scriptblock FAILED. Will retry in {2}ms ... [{0}/{1}]" -f $currentAttempt, $MaxAttempts, $currentWaitTimeMs);
					Start-Sleep -Milliseconds $currentWaitTimeMs;
				}
				else
				{
					Log-Error $fn ("Executing scriptblock FAILED. Exceeded maximum retries. [{0}/{1}]" -f $currentAttempt, $MaxAttempts);
				}
			}
		}

		switch($RetryStrategy)
		{
			"Exponential"
			{
				$currentWaitTimeMs *= 2;
			}
			"Incremental"
			{
				$currentWaitTimeMs += $InitialWaitTimeInMilliseconds;
			}
			"Fixed"
			{
				# do not change wait time
			}
			Default
			{
				Contract-Assert (!$RetryStrategy) 'Invalid value'
			}
		}
	}
	while($currentAttempt -lt $MaxAttempts);
	
	$OutputParameter = $result;
	return $OutputParameter;
}

End 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}

}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Invoke-WithRetry; } 

#
# Copyright 2016 d-fens GmbH
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUutrYXv0p89AYg21vSjngEJnr
# 6BGgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRKWuVKivM4xffM
# 0OmCxWa7ngRtSTANBgkqhkiG9w0BAQEFAASCAQADezROid6fpnMgnpnitW9B1BNs
# jLvVjvsLimwNM3hrWoqRj39qGpPAdWlKN5PZiTEshdjrF1/ybINhUfAHKu5OTbVZ
# YAMuI7of72k5PxYTAgh8xO6g40bhKbZj7hI5kSO8XAo3sQGzc+L+cbYxPNFzG2O4
# Y/LY1yIv0WVAJSzkkNCLZdBg6OXm4s2NjEbhVVyP1rHbgl4xDhUkESukmjWAlABb
# hhGNsquPxOoAMoP07PAX7oE7q55tlViAlmlTLvXesZhPiJfPk147pfq0SHotz42J
# K1x+60nXg2nrGQYzNNOKWyI3Z1+L9DD0WPNpOuQPtIj9Q9vSr6WdNV9JC8L1oYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDEwMTIyMjcxN1owIwYJKoZIhvcNAQkEMRYEFEcXRfxQHf717xlC4IBimSkumiJw
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQACBG9Q5z0S6Gsa2j7+
# 0XbUtfdhady3qHESKTwqC3GAtS4+BGMJrNDtjASuLvcxTAF8dlp8U+Tblp6eIIqS
# NZ3YBYKEPQRC+NHT+co9LhlIayEIEiGDd9Hzcl9yYwMyg/qsE07MLHOYRS8YHGjd
# FczN/+jbC/UZPNtT06m+0Bbn4JAxyU8B8dQ2dE6ntfu6U3mpONB6cevQL+tjik58
# WUADMpph18Ev3/7xDmYE5QzI1EZisCQiwu+L53/+rpsDgGQ1ZwjlkAJ4ZpI8oGLl
# 1YhYUYnpTe6jhqRnOYxsEO5WsW4bAfA/4uhFKdj7rnAOecWGYzGVOuWuwsgR/v3X
# UXu8
# SIG # End signature block
