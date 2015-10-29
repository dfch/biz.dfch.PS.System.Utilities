function Send-ShortMessage {
<#
.SYNOPSIS

Sends a short message (SMS) to a Short Message Provider

.DESCRIPTION

Sends a short message (SMS) to a Short Message Provider

Multiple numbers can be piped to the Cmdlet. Numbers must be in international 
format (only numbers, no leading zero, '+', space or '-').

Currently 'Clickatell' is the only supported provider. Messages are sent via 
the REST API (https://www.clickatell.com/help/apidocs/).

.INPUTS

You can pipe an array of telephone numbers (as String objects) to the Cmdlet.

.OUTPUTS

The Cmdlet returns a hashtable per recipient containing the following keys:
accepted       True|False depending on result of operation
apiMessageId   message id of SMS sent
to             recipient of message
code           error code if sending failed
description    error description if sending message failed

.EXAMPLE
Send-ShortMessage 27999112345 'hello, world!' -Credential e2c479178dd741aabe4d05c25db9b9b3
Name                           Value
----                           -----
apiMessageId                   2249157aa12e410398ce8e72f6108a36
accepted                       True
to                             27999112345

Send an SMS to '27999112345' (Clickatell test range) with the message text 'hello, world!' 
and the authentication token 'e2c479178dd741aabe4d05c25db9b9b3'.

=== HTTP REQUEST ===
POST https://api.clickatell.com/rest/message HTTP/1.1
Authorization: Bearer e2c479178dd741aabe4d05c25db9b9b3
X-Version: 1
User-Agent: Mozilla/5.0 (Windows NT; Windows NT 6.1; en-US) WindowsPowerShell/3.0
Content-Type: application/json
Host: api.clickatell.com
Content-Length: 46

{"text":"'hello, world!","to":["27999112345"]}

=== HTTP RESPONSE ===
HTTP/1.1 202 Accepted
Date: Mon, 16 Feb 2015 07:35:05 GMT
Server: Apache
Content-Length: 109
Content-Type: application/json

{"data":{"message":[{"accepted":true,"to":"27999112345","apiMessageId":"2249157aa12e410398ce8e72f6108a36"}]}}

.EXAMPLE
'27999112345','27999112346' | Send-ShortMessage -Message 'hello, world!' -Credential e2c479178dd741aabe4d05c25db9b9b3

Send an SMS to '27999112345' and '27999112346' with the message text 'hello, world!' 
and the authentication token 'e2c479178dd741aabe4d05c25db9b9b3'.


.EXAMPLE
'333' | Send-ShortMessage -Message 'hello, world!' -Credential e2c479178dd741aabe4d05c25db9b9b3
Name                           Value
----                           -----
apiMessageId                   
accepted                       False
to                             333
code                           105
description                    Invalid Destination Address

Tries to send an SMS to '333' with the message text 'hello, world!' and the authentication 
token 'e2c479178dd741aabe4d05c25db9b9b3'. This fails as the specified telephone number is invalid.

=== HTTP REQUEST ===
POST https://api.clickatell.com/rest/message HTTP/1.1
Authorization: Bearer e2c479178dd741aabe4d05c25db9b9b3
X-Version: 1
User-Agent: Mozilla/5.0 (Windows NT; Windows NT 6.1; en-US) WindowsPowerShell/3.0
Content-Type: application/json
Host: api.clickatell.com
Content-Length: 37
Connection: Keep-Alive

{"text":"hello, world!","to":["333"]}

=== HTTP RESPONSE ===
HTTP/1.1 400 Bad Request
Date: Mon, 16 Feb 2015 07:34:26 GMT
Server: Apache
Content-Length: 208
Connection: close
Content-Type: application/json

{"data":{"message":[{"accepted":false,"to":"333","apiMessageId":"","error":{"code":"105","description":"Invalid Destination Address","documentation":"http://www.clickatell.com/help/apidocs/error/105.htm"}}]}}


.EXAMPLE
Send-ShortMessage 27999112345 'hello, world!' -Credential e2c479178dd741aabe4d05c25db9b9b3 -From mySenderID
Name                           Value
----                           -----
apiMessageId                   2249157aa12e410398ce8e72f6108a36
accepted                       True
to                             27999112345

Send an SMS to '27999112345' (Clickatell test range) with the message text 'hello, world!' 
and the authentication token 'e2c479178dd741aabe4d05c25db9b9b3' and specify 'mySenderID' 
as the SenderID (must be configured with your provider).

.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Send-ShortMessage/


.NOTES

See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


#>
[CmdletBinding(
	SupportsShouldProcess = $true
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Send-ShortMessage/'
)]
Param (
	# Specifies the recipient's telephone number
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
	[alias("to")]
	[alias("Rescipient")]
	$InputObject
	,
	# Specfies the message to send. This can be larger than 160 characters and 
	# will be automatically concatenated (depending on MaxParts parameter).
	[Parameter(Mandatory = $true, Position = 1)]
	[alias("text")]
	[String] $Message
	,
	# Specfies the sender id of the message. This can a number of letters, numbers or 
	# will be automatically concatenated (depending on MaxParts parameter).
	[ValidatePattern("^[a-zA-Z\ \d]{1,11}$")]
	[Parameter(Mandatory = $false)]
	[alias("SenderID")]
	[String] $From
	,
	# Specifies the authentication token, can be either a plain string or a PSCredential object
	[Parameter(Mandatory = $true)]
	[alias("password")]
	[alias("token")]
	$Credential
	,
	# Specify the maximum credits to spend on the message,
	# this setting might have no effect when overriden in provider's API definition
	[Parameter(Mandatory = $false)]
	[int] $MaxCredits
	,
	# Specifies the maximum parts of the message (if longer than 160 chars),
	# this setting might have no effect when overriden in provider's API definition
	[Parameter(Mandatory = $false)]
	[int] $MaxParts
	,
	# Specifies the provider via which to send the message
	[ValidateSet('Clickatell')]
	[Parameter(Mandatory = $false)]
	[String] $Provider = 'Clickatell'
)

BEGIN
{
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = @();
	$OutputParameterPrepare = New-Object System.Collections.ArrayList;
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug $fn ("CALL. Message[length: {0}] to '{1}' via '{2}'" -f $Message.Length, ((Out-String -InputObject $InputObject).Replace([environment]::NewLine, ',').TrimEnd(',')), $Provider);
	# Check authentication token
	if($Provider -eq 'Clickatell')
	{
		if($Credential -is [PSCredential])
		{
			if(![String]::IsNullOrWhiteSpace($Credential.GetNetworkCredential().Password))
			{
				$Credential = $Credential.GetNetworkCredential().Password;
			}
			else
			{
				$Credential = $Credential.UserName;
			}
		}
		elseif($Credential -is [String])
		{
			# String is ok, nothing to do.
		}
		else
		{
			$msg = "Credential: Parameter validation FAILED."
			$e = New-CustomErrorRecord -m $msg -cat InvalidArgument -o $Credential;
			$PSCmdlet.ThrowTerminatingError($e);
		}

		$Uri = 'https://api.clickatell.com/rest/message';
		$headers = @{};
		# tricky - version must be set as string, otherwise Invoke-RestMethod call fails
		# this is not a PowerShell issue but due to the Clickatell API
		$headers.'X-Version' = '1';
		$headers.'Authorization' = ( "Bearer {0}" -f $Credential );
		if($PSBoundParameters.ContainsKey('MaxCredits'))
		{
			$headers.maxCredits = $MaxCredits.ToString();
		}
		if($PSBoundParameters.ContainsKey('MaxParts'))
		{
			$headers.maxMessageParts = $MaxParts.ToString();
		}
	}
}
PROCESS
{
	try
	{
		# Currently only clickatell is supported. If there is more than one 
		# provider in the future, this should be moved to a separate sub-function.
		# if($Provider -eq 'Clickatell')
		# {
			# # Invoke-ClickatellSubFunction ...
		# }
		foreach($Object in $InputObject) 
		{
			# Clickatell specific basic number normalisation
			$Object = $Object.ToString().Replace('+', '').Replace('-','').Replace(' ','');
			# escape new line etc
			$Object = $Object.Replace("`n", '\n\n');
			
			if($PSCmdlet.ShouldProcess( (("{0}: {1}" -f $Object, $Message)) ))
			{
				# The 'to' parameter MUST be set as an array, even if only one recipient is specified.
				$Body = @{};
				$Body.to = @($Object.ToString());
				$Body.text = $Message;
				if($PSBoundParameters.ContainsKey('From'))
				{
					$Body.from = $From;
				}
				try
				{
					# In PS 3.0 we cannot set an 'Accept' header, it is sufficient to only set 'Content-Type'.
					# See https://connect.microsoft.com/PowerShell/feedback/details/757249/invoke-restmethod-accept-header
					$BodyJson = ($Body | ConvertTo-Json -Compress);
					$BodyJson = $BodyJson.Replace('\\n', '');
					$r = Invoke-RestMethod -Method POST -Uri $Uri -ContentType 'application/json' -Headers $headers -Body $BodyJson;
					if($r.error)
					{
						$ApiResponse = $r.error;
						$r2 = @{};
						$r2.accepted = $false;
						$r2.code = $ApiResponse.code;
						$r2.to = [String]::Empty;
						$r2.apiMessageId = [String]::Empty;
						$r2.description = $ApiResponse.description;
						$null = $OutputParameterPrepare.Add($r2);
					}
					else
					{
						$ApiResponse = $r.data.message;
						$r2 = @{};
						$r2.accepted = $ApiResponse.accepted;
						$r2.to = $ApiResponse.to;
						$r2.apiMessageId = $ApiResponse.apiMessageId;
						$null = $OutputParameterPrepare.Add($r2);
					}
				}
				catch [System.Net.WebException]
				{
					# http://stackoverflow.com/questions/18771424/how-to-get-powershell-invoke-restmethod-to-return-body-of-http-500-code-response
					$result = $_.Exception.Response.GetResponseStream();
					$reader = New-Object System.IO.StreamReader($result);
					$reader.BaseStream.Position = 0;
					$reader.DiscardBufferedData();
					$responseBody = $reader.ReadToEnd();
					$ApiResponse = (ConvertFrom-Json -InputObject $responseBody).data.message;
					$r2 = @{};
					$r2.accepted = $ApiResponse.accepted;
					$r2.to = $ApiResponse.to;
					$r2.apiMessageId = $ApiResponse.apiMessageId;
					$r2.code = $ApiResponse.error.code;
					$r2.description = $ApiResponse.error.description;
					$null = $OutputParameterPrepare.Add($r2);
					Log-Error $fn ($r2 | Out-String);
				}
			}
		}
	}
	# catch
	# {
		# No need to catch here, as we already did in inner block
		# $_.GetType();
	# }
	finally
	{
		# N/A
	}
}
END
{
	# $datEnd = [datetime]::Now;
	# Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	$OutputParameter = $OutputParameterPrepare.ToArray();
	return $OutputParameter;
}

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Send-ShortMessage; } 

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkOlD8T5yydCQEOqW05IS2xe8
# 4++gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRZemJXwB34IWBr
# WyXPWiY11kmR4TANBgkqhkiG9w0BAQEFAASCAQBqw36ru7B1f8eVKy9tySZG2LjW
# cAao8/vj/UX9QlKRWx0HF3Z8GDqdk14BcsJQchTLGPh0IDViaMS0/NRhqGWHXUxv
# lVzUpJgB9c5cJQH5uHApcCV+jD4pgPWg0cc4CCTSrx4mPSXPkbxHyDK8Sn+lGY79
# n+bypliVWa3W75sBvj+8bmXEtxUnxSpk7b2fLAoix7i0iRO7+wm6GR78ZHqXP8op
# LDF6AobAxMFsRi+sJ0N5sMOsMrwrQRCNbZs5HRW4jZQuum5uKmUkxuMM2p8X+k9n
# Q+uQlPXJB5Ra7hEtivvOQP1nXQ48m0PZDu1xv9Okx4yVDnUnGhYymaQHPsA0oYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTAxODExMDMxNVowIwYJKoZIhvcNAQkEMRYEFAWibimZHEmeUDIYNoLKW3wRmLub
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQB/tiyu4fquwhWVFa/J
# urjiFmW0cbJfYoOmZ363JgrNkunS2hhh3nXo8HIRQ2Yz80r+5HBXLF+NblibQJC8
# vB3DsWElPjZeu0oFswnn6hiQOPwDnaFJeBifiBWtessEs9euePJ8Q5rmoW/LNNUG
# 9+KITuBKHBVSSvectuRMkmrWuC0GEEIhSeuypusg+C3ET1hLTkhgiM02uTr7JrUD
# QnU5wnQO1HIILPzNGrwPVfSw0tVSHqOsmkRKA3V/GrZ/j7Q9UKxadKJqU+B9HIgq
# D9ESnYpU7PTvDg+gn9gr4qIlg4OhZYTwoQ74XVFIFyGCgXQGN0ZROn06ngObZ0J/
# OQ4x
# SIG # End signature block
