Function Merge-Hashtable {
<#
.SYNOPSIS
Merges two hashtables and creates a resulting hashtable from both sources.


.DESCRIPTION
Merges two hashtables and creates a resulting hashtable from both sources.

Input can be either a positional or named parameters of type hashtable. You 
can specify the merge behaviour via the 'Action' parameter.


.EXAMPLE
# Effectively merges two hashtables and returns the returned hashtable.

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key2 = 'value2-left';

PS > $htRight = @{};
PS > $htRight.key3 = 'value3-right';
PS > $htRight.key4 = 'value4-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight;

PS > $result
Name Value
---- -----
key1 value1-left
key2 value2-left
key3 value3-right
key4 value4-right


.EXAMPLE
# Merges two hashtables and overwrites all keys from the Left hashtable with the values from the Right hashtable

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key2 = 'value2-left';

PS > $htRight = @{};
PS > $htRight.key1 = 'value1-right';
PS > $htRight.key3 = 'value3-right';
PS > $htRight.key4 = 'value4-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;

PS > $result
Name Value
---- -----
key1 value1-right
key2 value2-left
key3 value3-right
key4 value4-right


.EXAMPLE
# Returns the intersection of two hashtables and takes the value from the 'Left' hashtable

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key2 = 'value2-left';

PS > $htRight = @{};
PS > $htRight.key1 = 'value1-right';
PS > $htRight.key3 = 'value3-right';
PS > $htRight.key4 = 'value4-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersection;

PS > $result
Name Value
---- -----
key1 value1-left


.EXAMPLE
# Returns the outersection (or difference set) of two hashtables

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key2 = 'value2-left';

PS > $htRight = @{};
PS > $htRight.key1 = 'value1-right';
PS > $htRight.key3 = 'value3-right';
PS > $htRight.key4 = 'value4-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersection;

PS > $result
Name Value
---- -----
key2 value2-left
key3 value3-right
key4 value4-right


.EXAMPLE
# Tries to merge two hashtables with duplicate keys. Result will be $null

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key3 = 'value3-left';

PS > $htRight = @{};
PS > $htRight.key1 = 'value1-right';
PS > $htRight.key2 = 'value2-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;

PS > $result -eq $null
True


.EXAMPLE
# Tries to merge two hashtables with duplicate keys. An exception will be thrown

PS > $htLeft = @{};
PS > $htLeft.key1 = 'value1-left';
PS > $htLeft.key3 = 'value3-left';

PS > $htRight = @{};
PS > $htRight.key1 = 'value1-right';
PS > $htRight.key2 = 'value2-right';

PS > $result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;

Exception calling "Add" with "2" argument(s): "Item has already been added. Key in dictionary: 'key1'  Key being added: 'key1'"
At .\Merge-Hashtable.ps1:152 char:4
+             $result.Add($i.Name, $i.Value);
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : ArgumentException


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Merge-Hashtable/



.NOTES

See module manifest for required software versions and dependencies at: http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


#>
[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Merge-Hashtable/'
)]
[OutputType([hashtable])]

PARAM
(
	# Specifies the first (left) input hashtable
	[ValidateNotNull()]
	[Parameter(Mandatory = $true, Position = 0)]
	[hashtable] $Left
	,
	# Specifies the second (right) input hashtable
	[ValidateNotNull()]
	[Parameter(Mandatory = $true, Position = 1)]
	[hashtable] $Right
	,
	# Specifies the action on how to merge hashtables
	# 'OverwriteLeft' and 'KeepRight'
	#     effectively copies the Right hashtable over the Left hashtable
	# 'OverwriteRight' and 'KeepLeft' 
	#     effectively copies the Left hashtable over the Right hashtable
	# 'FailOnDuplicateKeys' 
	#     effectively merges both hashtables and returns $null 
	#     if the keys of both hashtables are not distinct
	# 'ThrowOnDuplicateKeys' 
	#     effectively merges both hashtables and throws an exception 
	#     if the keys of both hashtables are not distinct
	# 'Intersect'
	#     returns the intersection of both hashtables
	#     value of duplicate keys is implicitly taken from the 'Left' hashtable
	# 'Outersect'
	#     returns the keys and values of both hashtables 
	#     that do not exist in both hashtables
	[ValidateSet('OverwriteLeft', 'OverwriteRight', 'KeepLeft', 'KeepRight', 'FailOnDuplicateKeys', 'ThrowOnDuplicateKeys', 'Intersect', 'Outersect')]
	[Parameter(Mandatory = $false, Position = 2)]
	[String] $Action = 'FailOnDuplicateKeys'
)

BEGIN 
{
	# $datBegin = [datetime]::Now;
	# [string] $fn = $MyInvocation.MyCommand.Name;
	# Log-Debug -fn $fn -msg ("CALL. Left: {0}; Right: {1}" -f $Left.Count, $Right.Count) -fac 1;
}

PROCESS 
{
	$fReturn = $false;
	$OutputParameter = $null;
	
	$result = $Left.Clone();

	foreach($i in $Right.GetEnumerator()) 
	{ 
		if($Action -ieq 'OverwriteLeft' -Or $Action -ieq 'KeepRight')
		{
			$result.($i.Name) = $i.Value;
		}
		elseif($Action -ieq 'OverwriteRight' -Or $Action -ieq 'KeepLeft')
		{
			if(!$Left.ContainsKey($i.Name))
			{
				$result.($i.Name) = $i.Value;
			}
		}
		elseif($Action -ieq 'FailOnDuplicateKeys')
		{
			if($Left.ContainsKey($i.Name))
			{
				$result = $null;
				break;
			}
			$result.($i.Name) = $i.Value;
		}
		elseif($Action -ieq 'ThrowOnDuplicateKeys')
		{
			$result.Add($i.Name, $i.Value);
		}
		elseif($Action -ieq 'Intersect')
		{
			if(!$result.ContainsKey($i.Name))
			{
				$result.Remove($i.Name);
			}
		}
		elseif($Action -ieq 'Outersect')
		{
			if($result.ContainsKey($i.Name))
			{
				$result.Remove($i.Name);
			}
			else
			{
				$result.Add($i.Name, $i.Value);
			}
		}
		else
		{
			$e = New-CustomErrorRecord -m ('{0}: Parameter validation FAILED.' -f $Action) -cat InvalidArgument -o $Action;
			$PSCmdlet.ThrowTerminatingError($e);
		}
	}
	if($Action -ieq 'Intersect')
	{
		foreach($i in $htLeft.GetEnumerator())
		{
			if(!$htRight.ContainsKey($i.Name))
			{
				$result.Remove($i.Name);
			}
		}
	}
	
	$OutputParameter = $result;
	return $OutputParameter;
}

END 
{
	# $datEnd = [datetime]::Now;
	# Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Merge-Hashtable; } 

#
# Copyright 2015 d-fens GmbH
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEiOkDzJ8D+7LUsH+fn3/GGOV
# NASgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTYwNTI0MDAwMDAwWhcNMjcwNjI0MDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
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
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAj6kakW0EpjcgDoOW3iPTa24f
# bt1kPWghIrX4RzZpjuGlRcckoiK3KQnMVFquxrzNY46zPVBI5bTMrs2SjZ4oixNK
# Eaq9o+/Tsjb8tKFyv22XY3mMRLxwL37zvN2CU6sa9uv6HJe8tjecpBwwvKu8LUc2
# 35IgA+hxxlj2dQWaNPALWVqCRDSqgOQvhPZHXZbJtsrKnbemuuRQ09Q3uLogDtDT
# kipbxFm7oW3bPM5EncE4Kq3jjb3NCXcaEL5nCgI2ZIi5sxsm7ueeYMRGqLxhM2zP
# TrmcuWrwnzf+tT1PmtNN/94gjk6Xpv2fCbxNyhh2ybBNhVDygNIdBvVYBAexGDCC
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS/YRB/O2caLhU4
# e9g1RymgWHPCMjANBgkqhkiG9w0BAQEFAASCAQCss0LrZ2hBufLMh+LlbZfAK3BD
# Zh6woNDBH7of50+dXRI8q8yAxwDQYIQHXPES8rKCwVG7fjHrPIDD60kj1JsVoMpY
# aXrms80btwx/JAd4h+XaYs8l4gKTENr5GNHzYF8F71Rpvn8HG62K5dAu3w/sdwkm
# 4WKgXAcR3iZikQzr3FzSJ8QkBqpmkIQ7vytd2nx2IyQZdfFLdMnF4vGbrZHF7bt/
# QK2HLWdVcEUh2kgHJAqHlxrj9ID07Fte7QVIzpKwDWduGa8Hnn+OIWG/4ZNVIQDR
# 4tf/8UI+d9+bbKE0gy8R2TLWM2CDQR1tgV/8ut/PFgCzM9wG/3g5rtdD4a2voYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyMzE4NTk1MFowIwYJKoZIhvcNAQkEMRYEFKYSAAWU6QK4QjT/jrlQ//6CJVuv
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQCv6y/9jYKBGDDooDUL
# zFxsQzlK0sqbpYAp9phXOV+eJcdl0rK2K2Qnpua7/8hLIF4JOyVFvJtC5CoGfC3G
# 1Jo/qx4m8UkEtyzf4uY01Bjfgup9GW4fkLEIz96fa+Ki4+EtF3qsxz8M3vLZIl2Z
# 6Pq17NGGsE/K5CDHJ9wtKAND1J94O6/FYlGJ7sM2My6mV2lLAn4T0wfZUS1DR4da
# ygEbtIe6x5bSy+41dJ2kEXBGlFG9wXc0vFiTXR7Xl6OekwqTK+0O+A0n/2XFJpU6
# R1kRc+LHW7SGUQTfC+DaETR2v550aBBYANYI8+B3p2XjRiZ06F4TMKJtjugn0qho
# gf6E
# SIG # End signature block
