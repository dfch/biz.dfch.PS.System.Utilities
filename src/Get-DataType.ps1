function Get-DataType {
<#
.SYNOPSIS
Retrieves information about a .NET data type.

.DESCRIPTION
Retrieves information about a .NET data type.

You can search for arbitrary data types that loaded in the current PowerShell 
session via exact name or regex search patterns (default).
In addition you can also display the constructor of all found data types.

.INPUTS
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

In addition output can be filtered on specified properties.

.EXAMPLE
# Searches for all data types that contain 'System.Uri'
PS > Get-DataType System.Uri
System.Uri
System.UriBuilder
System.UriComponents
System.UriFormat
System.UriFormatException
System.UriHostNameType
System.UriIdnScope
System.UriKind
System.UriParser
System.UriPartial
System.UriTemplate
System.UriTemplateEquivalenceComparer
System.UriTemplateMatch
System.UriTemplateMatchException
System.UriTemplateTable
System.UriTypeConverter

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri'
PS > Get-DataType System.Uri -Literal
System.Uri

.EXAMPLE
# Searches for all data types that end with 'System.Uri'
PS > Get-DataType System.Uri$
System.Uri

.EXAMPLE
# Searches for all data types that end with 'System.Uri' (case sensitive)
PS > Get-DataType System.Uri$ -Case
System.Uri

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri' 
# and also display their public constructors
PS > Get-DataType System.Uri -Literal -IncludeConstructor
System.Uri
Uri(
        String uriString,
)
Uri(
        String uriString,
        Boolean dontEscape,
)
Uri(
        Uri baseUri,
        String relativeUri,
        Boolean dontEscape,
)
Uri(
        String uriString,
        UriKind uriKind,
)
Uri(
        Uri baseUri,
        String relativeUri,
)
Uri(
        Uri baseUri,
        Uri relativeUri,
)

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri' 
# and also display their public constructors
PS > Get-DataType System.Uri -prop -ctor
Name           PropertyType
----           ------------
AbsolutePath   System.String
AbsoluteUri    System.String
LocalPath      System.String
Authority      System.String
HostNameType   System.UriHostNameType
IsDefaultPort  System.Boolean
IsFile         System.Boolean
IsLoopback     System.Boolean
PathAndQuery   System.String
Segments       System.String[]
IsUnc          System.Boolean
Host           System.String
Port           System.Int32
Query          System.String
Fragment       System.String
Scheme         System.String
OriginalString System.String
DnsSafeHost    System.String
IdnHost        System.String
IsAbsoluteUri  System.Boolean
UserEscaped    System.Boolean
UserInfo       System.String
Uri(
        String uriString,
)
Uri(
        String uriString,
        Boolean dontEscape,
)
Uri(
        Uri baseUri,
        String relativeUri,
        Boolean dontEscape,
)
Uri(
        String uriString,
        UriKind uriKind,
)
Uri(
        Uri baseUri,
        String relativeUri,
)
Uri(
        Uri baseUri,
        Uri relativeUri,
)

.EXAMPLE
# Searches for all data types that derive from 
# System.ValueType
PS > Get-DataType System.ValueType -base
System.Enum
System.Guid
System.Int16
System.Int32
System.Int64
System.IntPtr
...

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Get-DataType/

.NOTES
See module manifest for required software versions and dependencies.

#>
[CmdletBinding(
	SupportsShouldProcess = $false
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Get-DataType/'
)]
PARAM
(
	# Data Type to search for. Input is treated as regular expression
	# unlesse otherwise specified in '-Literal'
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $InputObject = '.*'
	,
	# perform case sensitive search if specified
	[Parameter(Mandatory = $false)]
	[Alias('case')]
	[switch] $CaseSensitive = $false
	,
	# perform literal search (i.e. not regex) if specified
	[Parameter(Mandatory = $false)]
	[Alias('noregex')]
	[switch] $Literal = $false
	,
	# also show the constructor of the data type
	[Parameter(Mandatory = $false)]
	[Alias('ctor')]
	[switch] $IncludeConstructor = $false
	,
	# returns an instantiated object of the types found
	[Parameter(Mandatory = $false)]
	[Alias('prop')]
	[switch] $IncludeProperties = $false
	,
	# Specifies that InputObject contains the BaseType of the data types 
	# to return
	[Parameter(Mandatory = $false)]
	[Alias('base')]
	[switch] $BaseType = $false
	,
	# Specifies an AssemblyName to limit search scope
	[Parameter(Mandatory = $false)]
	[Alias('Assembly')]
	[string] $AssemblyName
)
	$dataTypes = New-Object System.Collections.ArrayList;
	$constructors = New-Object System.Collections.ArrayList;
	
	$assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies();
	foreach($assembly in $assemblies)
	{
		# only look in matching assembly if specified
		if($AssemblyName -And ($assembly.Modules.Name -notmatch $AssemblyName) )
		{
			continue;
		}
		
		foreach($definedType in $assembly.DefinedTypes)
		{
			# only filter public and nested classes, skip interfaces
			if(!(($definedType.IsPublic -eq $true -Or $definedType.IsNestedPublic -eq $true) -And $definedType.IsInterface -ne $true))
			{
				continue;
			}
			
			$definedTypeFullName = $definedType.FullName;
			# swap base type into type name to enable search
			if($BaseType)
			{
				$definedTypeFullName = $definedType.BaseType.FullName;
			}
			if($Literal)
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cne $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -ine $InputObject)
					{
						continue;
					}
				}
			}
			else
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cnotmatch $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -inotmatch $InputObject)
					{
						continue;
					}
				}
			}
			
			# swap original type name back (because of BaseType switch)
			$definedTypeFullName = $definedType.FullName;

			# data type goes into 1st list (a real list)
			if($IncludeProperties)
			{
				try
				{
					$obj = $definedType.GetProperties() | Select Name, PropertyType;
					$null = $dataTypes.Add($obj);
				}
				catch
				{
					$null = $dataTypes.Add($definedTypeFullName);
				}
			}
			else
			{
				$null = $dataTypes.Add($definedTypeFullName);
			}
			
			# constructor information goes into 2nd list (a list of constructor display strings)
			if(!$IncludeConstructor)
			{
				continue;
			}
			$null = $constructors.Add((Get-Constructor $definedTypeFullName));
		}
	}
	
	Write-Output ($dataTypes | Sort);
	if($IncludeConstructor -And (0 -lt $constructors.Count))
	{
		Write-Output ($constructors);
	}
}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-DataType; } 

#
# Copyright 2012-2016 d-fens GmbH
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKJj0LrpGSsDdlgl78SyUliJV
# AfCgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTwh3ljp4qYq+1W
# Qu9QIvuVdIhHqjANBgkqhkiG9w0BAQEFAASCAQA4sbBv/FYf14JAVxxc8a+I6uo6
# 2zXuFYR4kbi7v+kOreW5qyonMmEG8wbJjEwGFn1f0z4Y/4t1EagpZPzRCaKqC9vH
# YxIbR7emcTYVVgcWMJ9AHFDtmyKIbCVRfQvyjmOI0SBv/ZA2dR4zobzpfRBv2CDj
# eRa+sK6FabtB4c4rg25baPmSZOsJbhBA7wnBUYWs3kIa8keGVR3ZN+Yyx/TeGmPI
# 3xxJGfGv8hLB7I2ysBLaHAT1TJlYyytv5jeoUVuoqcVMjW0l0EpEBXREkaTAzAKb
# hJJQrc3OOhBIawdpXW3K8KWCu70oGFqoCilntpmcOTiHrfLbPgqf/4yclvyqoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyMzE3MzkzN1owIwYJKoZIhvcNAQkEMRYEFBr+O6luJi5AvNKvrHgRHQQIohbN
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQCTtkHkhCjgVUdFeLx2
# 8eqNvbdgttptJ8BXLlCdMey9+VW0yrGLGndGWZtFlPB5HvjKg/EZ5GQnlSXo+xYG
# Vnu8Z0b7tRZ4m0dnI+5rZkpTC+fMZE+6bWg8LR/MH5N+Jn9iyrhsyc3GaRVLUqBg
# L16pX5663JmS+0VYSUE94D3pW86JOoBzV9DEqtb4LorZLOPJ42nyiJro02mzxKz0
# CeOheVLFWfkwWHPSsy9M2FIMQIRJJhOBDhV/f8PpZfvMQmycDhQLGjVpIArtifSJ
# kGB84mzlZajvmxMmejGl7w4zRtZVZBSuRHl7aorALCeC4BrzmOv8DLSWq+tSa9RZ
# jzyy
# SIG # End signature block
