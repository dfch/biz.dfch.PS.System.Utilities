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
Send-ShortMessage 27999112345 'hello, world!' e2c479178dd741aabe4d05c25db9b9b3
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
'27999112345',27999112346' | Send-ShortMessage -Message 'hello, world!' e2c479178dd741aabe4d05c25db9b9b3

Send an SMS to '27999112345' and '27999112346' with the message text 'hello, world!' 
and the authentication token 'e2c479178dd741aabe4d05c25db9b9b3'.


.EXAMPLE
'333' | Send-ShortMessage -Message 'hello, world!' e2c479178dd741aabe4d05c25db9b9b3
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
			if($PSCmdlet.ShouldProcess( (("{0}: {1}" -f $Object, $Message)) ))
			{
				# The 'to' parameter MUST be set as an array, even if only one recipient is specified.
				$Body = @{};
				$Body.to = @($Object.ToString());
				$Body.text = $Message;
				try
				{
					# In PS 3.0 we cannot set an 'Accept' header, it is sufficient to only set 'Content-Type'.
					# See https://connect.microsoft.com/PowerShell/feedback/details/757249/invoke-restmethod-accept-header
					$r = Invoke-RestMethod -Method POST -Uri $Uri -ContentType 'application/json' -Headers $headers -Body ($Body | ConvertTo-Json -Compress);
					$ApiResponse = $r.data.message;
					$r2 = @{};
					$r2.accepted = $ApiResponse.accepted;
					$r2.to = $ApiResponse.to;
					$r2.apiMessageId = $ApiResponse.apiMessageId;
					$OutputParameter += $r2;
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
					$OutputParameter += $r2;
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
	return $OutputParameter;
}
END
{
	# $datEnd = [datetime]::Now;
	# Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}

} # function
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Send-ShortMessage; } 

<#
2015-03-15; rrink; CHG: #3, #4 - documentation and structure
2015-02-16; rrink; ADD: initial version
#>

# SIG # Begin signature block
# MIIaVQYJKoZIhvcNAQcCoIIaRjCCGkICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyRAx4ko+BlEEtKI2xvNxYKN6
# C4ygghURMIIDdTCCAl2gAwIBAgILBAAAAAABFUtaw5QwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw05ODA5
# MDExMjAwMDBaFw0yODAxMjgxMjAwMDBaMFcxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJH
# bG9iYWxTaWduIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDaDuaZjc6j40+Kfvvxi4Mla+pIH/EqsLmVEQS98GPR4mdmzxzdzxtIK+6NiY6a
# rymAZavpxy0Sy6scTHAHoT0KMM0VjU/43dSMUBUc71DuxC73/OlS8pF94G3VNTCO
# XkNz8kHp1Wrjsok6Vjk4bwY8iGlbKk3Fp1S4bInMm/k8yuX9ifUSPJJ4ltbcdG6T
# RGHRjcdGsnUOhugZitVtbNV4FpWi6cgKOOvyJBNPc1STE4U6G7weNLWLBYy5d4ux
# 2x8gkasJU26Qzns3dLlwR5EiUWMWea6xrkEmCMgZK9FGqkjWZCrXgzT/LCrBbBlD
# SgeF59N89iFo7+ryUp9/k5DPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
# HRMBAf8EBTADAQH/MB0GA1UdDgQWBBRge2YaRQ2XyolQL30EzTSo//z9SzANBgkq
# hkiG9w0BAQUFAAOCAQEA1nPnfE920I2/7LqivjTFKDK1fPxsnCwrvQmeU79rXqoR
# SLblCKOzyj1hTdNGCbM+w6DjY1Ub8rrvrTnhQ7k4o+YviiY776BQVvnGCv04zcQL
# cFGUl5gE38NflNUVyRRBnMRddWQVDf9VMOyGj/8N7yy5Y0b2qvzfvGn9LhJIZJrg
# lfCm7ymPAbEVtQwdpf5pLGkkeB6zpxxxYu7KyJesF12KwvhHhm4qxFYxldBniYUr
# +WymXUadDKqC5JlR3XC321Y9YeRq4VzW9v493kHMB65jUr9TU/Qr6cf9tveCX4XS
# QRjbgbMEHMUfpIBvFSDJ3gyICh3WZlXi/EjJKSZp4DCCBBQwggL8oAMCAQICCwQA
# AAAAAS9O4VLXMA0GCSqGSIb3DQEBBQUAMFcxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMRAwDgYDVQQLEwdSb290IENBMRswGQYDVQQDExJH
# bG9iYWxTaWduIFJvb3QgQ0EwHhcNMTEwNDEzMTAwMDAwWhcNMjgwMTI4MTIwMDAw
# WjBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYG
# A1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMjCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAJTvZfi1V5+gUw00BusJH7dHGGrL8Fvk/yel
# NNH3iRq/nrHNEkFuZtSBoIWLZFpGL5mgjXex4rxc3SLXamfQu+jKdN6LTw2wUuWQ
# W+tHDvHnn5wLkGU+F5YwRXJtOaEXNsq5oIwbTwgZ9oExrWEWpGLmtECew/z7lfb7
# tS6VgZjg78Xr2AJZeHf3quNSa1CRKcX8982TZdJgYSLyBvsy3RZR+g79ijDwFwmn
# u/MErquQ52zfeqn078RiJ19vmW04dKoRi9rfxxRM6YWy7MJ9SiaP51a6puDPklOA
# dPQD7GiyYLyEIACDG6HutHQFwSmOYtBHsfrwU8wY+S47+XB+tCUCAwEAAaOB5TCB
# 4jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQU
# Rtg+/9zjvv+D5vSFm7DdatYUqcEwRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDMG
# A1UdHwQsMCowKKAmoCSGImh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5j
# cmwwHwYDVR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/UswDQYJKoZIhvcNAQEF
# BQADggEBAE5eVpAeRrTZSTHzuxc5KBvCFt39QdwJBQSbb7KimtaZLkCZAFW16j+l
# IHbThjTUF8xVOseC7u+ourzYBp8VUN/NFntSOgLXGRr9r/B4XOBLxRjfOiQe2qy4
# qVgEAgcw27ASXv4xvvAESPTwcPg6XlaDzz37Dbz0xe2XnbnU26UnhOM4m4unNYZE
# IKQ7baRqC6GD/Sjr2u8o9syIXfsKOwCr4CHr4i81bA+ONEWX66L3mTM1fsuairtF
# Tec/n8LZivplsm7HfmX/6JLhLDGi97AnNkiPJm877k12H3nD5X+WNbwtDswBsI5/
# /1GAgKeS1LNERmSMh08WYwcxS2Ow3/MwggQoMIIDEKADAgECAgsEAAAAAAEvTuE1
# XDANBgkqhkiG9w0BAQUFADBXMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEQMA4GA1UECxMHUm9vdCBDQTEbMBkGA1UEAxMSR2xvYmFsU2ln
# biBSb290IENBMB4XDTExMDQxMzEwMDAwMFoXDTE5MDQxMzEwMDAwMFowUTELMAkG
# A1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExJzAlBgNVBAMTHkds
# b2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBHMjCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBALJPFOcQvtcmcqs2l+9Tv0KEXljRiij8Q0ZvfihEUAt1XQDX
# PApEniBqpPdFSjdgo24/Evpt+rZGw2qjuAwnKAJXKNFQ92E5VbjD4SWGUjy/BR3X
# s5r4miQxSdWiqeLTkas+PHPv9inxyDXQMHt/TpKlBo+H4s71wWNmrBhpKsFeu1ro
# bpX/O4BinZnHxy9m1f1iGoJVWsb6QHeOyTA8G/DyNbhsWZz96dbKtEAe9wTK0Wep
# dOOlCFTZgzU7jowjDHW23oZKnho+ClBJOJzSqJC/mPrIjCsnEX4q+87eqa44kyL6
# puz7XGF2w0TWzAx+L20GgKJ0QLu3H/Q713NUH/MCAwEAAaOB+jCB9zAOBgNVHQ8B
# Af8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUCG7YtpyKv+0+
# 18N0XcyAH6gvUHowRwYDVR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEWJmh0
# dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMDMGA1UdHwQsMCow
# KKAmoCSGImh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5uZXQvcm9vdC5jcmwwEwYDVR0l
# BAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgwFoAUYHtmGkUNl8qJUC99BM00qP/8/Usw
# DQYJKoZIhvcNAQEFBQADggEBACJcxd099Atw2OP158WOCQG7sZY2XFoHrceoRElR
# JXquDaQZO5Kcz7lCJrs7bJfnx84RbWiR2o1t8VNNVDiMYfPIgnZpvoEyCzHDbMme
# IApYL/BI/n5IB6rXQ1iUc1QEMal4DTuMsHDBPX7XvS8qw+L1jwyQ3GulyL5oXl1t
# +HjSvkmVHhV4CJH7NMi+hK284MbdGNvzyvB7whQ8GLgDupU+IR4/YGl6f2oDno1K
# +fAoLDCEXuwmckKxbctkwxKM1oRLZ0F8sQMXeAnjrai2li2kfoADT4j3wWtaRhXN
# LBmL2HCc5S1JiGByqKQZUnBDXtrWRgOwaA4k70r2CyUk7yQwggSfMIIDh6ADAgEC
# AhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJKoZIhvcNAQEFBQAwUjELMAkGA1UEBhMC
# QkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNp
# Z24gVGltZXN0YW1waW5nIENBIC0gRzIwHhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAz
# MDAwMDAwWjBgMQswCQYDVQQGEwJTRzEfMB0GA1UEChMWR01PIEdsb2JhbFNpZ24g
# UHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFsU2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRp
# Y29kZSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2
# BDBWHlgPse1VpNZUy9j2czrsXV6rJf02pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPW
# kiWxfSPjBrOHOg5D8NcAiVOiETFSKG5dQHI88gl3p0mSl9RskKB2p/243LOd8gdg
# LE9YmABr0xVU4Prd/4AsXximmP/Uq+yhRVmyLm9iXeDZGayLV5yoJivZF6UQ0kcI
# GnAsM4t/aIAqtaFda92NAgIpA6p8N7u7KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3
# CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os+XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZ
# lzXeaoXmIwRCrwIDAQABo4IBXzCCAVswDgYDVR0PAQH/BAQDAgeAMEwGA1UdIARF
# MEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2Jh
# bHNpZ24uY29tL3JlcG9zaXRvcnkvMAkGA1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYI
# KwYBBQUHAwgwQgYDVR0fBDswOTA3oDWgM4YxaHR0cDovL2NybC5nbG9iYWxzaWdu
# LmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cyLmNybDBUBggrBgEFBQcBAQRIMEYwRAYI
# KwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dz
# dGltZXN0YW1waW5nZzIuY3J0MB0GA1UdDgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ
# 9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUF
# AAOCAQEAgDLcB40coJydPCroPSGLWaFNfsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4
# Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4A11P2RwumODpiObs1wV+Vip79xZbo62P
# lyUShBuyXGNKCtLvEFRHgoQ1aSicDOQfFBYk+nXcdHJuTsrjakOvz302SNG96QaR
# LC+myHH9z73YnSGY/K/b3iKMr6fzd++d3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUH
# Cya9vm0CXrG4sFhshToN9v9aJwzF3lPnVDxWTMlOTDD28lz7GozCgr6tWZH2G01V
# e89bAdz9etNvI1wyR5sB88FRFEaKmzCCBK0wggOVoAMCAQICEhEhYHff2l3ILeBb
# QgbbK6elMjANBgkqhkiG9w0BAQUFADBRMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQ
# R2xvYmFsU2lnbiBudi1zYTEnMCUGA1UEAxMeR2xvYmFsU2lnbiBDb2RlU2lnbmlu
# ZyBDQSAtIEcyMB4XDTEyMDYwODA3MjQxMVoXDTE1MDcxMjEwMzQwNFowejELMAkG
# A1UEBhMCREUxGzAZBgNVBAgTElNjaGxlc3dpZy1Ib2xzdGVpbjEQMA4GA1UEBxMH
# SXR6ZWhvZTEdMBsGA1UECgwUZC1mZW5zIEdtYkggJiBDby4gS0cxHTAbBgNVBAMM
# FGQtZmVucyBHbWJIICYgQ28uIEtHMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
# CgKCAQEA0xuKJFsjlEbmGME2xhqJI/pbwYKNHcDWCXux2fcKw1FAfjLD002S/Njt
# iDTB6UPP0BDLPO2mpcx89sLWDdXVCAVGnnVe02VZnuMnIwn4ua5S/qeOP74TVZ3d
# SGxf6cbu8jsJAMJ/4kfhVm3wMhaAk4SWJPWoD1dAs8xRQS3BLRKzySL6x6veLW0S
# U6h/bMqUH6xE6HuZAVpA2H4ne1NK1JB/5m33/07/O33dJiZAnzi+h+/6gomBdtEd
# tyssOw9n9ocvc03HYMylUj8ONVk7ELQd4tOasBGd0AoLpynw0grZXS+x03VvnH10
# NiByLTesx6VAGMVsKMliznFnEuvSJwIDAQABo4IBVDCCAVAwDgYDVR0PAQH/BAQD
# AgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEyMDQwMgYIKwYBBQUHAgEWJmh0dHBz
# Oi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkGA1UdEwQCMAAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwPgYDVR0fBDcwNTAzoDGgL4YtaHR0cDovL2NybC5n
# bG9iYWxzaWduLmNvbS9ncy9nc2NvZGVzaWduZzIuY3JsMFAGCCsGAQUFBwEBBEQw
# QjBABggrBgEFBQcwAoY0aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNl
# cnQvZ3Njb2Rlc2lnbmcyLmNydDAdBgNVHQ4EFgQU8CeCuljXweXmtZyEAx+frc3x
# QLowHwYDVR0jBBgwFoAUCG7YtpyKv+0+18N0XcyAH6gvUHowDQYJKoZIhvcNAQEF
# BQADggEBAAd2aLYyofO6O8cc5l44ImMR5fi/bZhfZ7o/0kl3wxF5p4Rs5JdXx0RK
# cl0lYAR2QF6jyp5ZgDAFo9Pk5ucgEyr1evNh5QkIvp2Yxt7SIbk1Gy3bt+W7LOdF
# OOMzQ6q/uMBD8M7hTFJ2BdoRW2M8WTBAF1ZZ2o/gqrTBej/0mTcRb2gIJxGNULyF
# yNqWFc90YQ+FXQz5jBb9D/YkPp6QtaZjS5gmhu86X31Bb2Q7l+sVJc7zotJ606PT
# ORdsOy21ks2V3nWpugzBtJ0dV3MdKsvcGJ6uDbMrcD21MvmqZmVUmpUr5XYjQwH5
# nSj9Ego8lcJPdsYDcWBcCEybjUCLaOMxggSuMIIEqgIBATBnMFExCzAJBgNVBAYT
# AkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxT
# aWduIENvZGVTaWduaW5nIENBIC0gRzICEhEhYHff2l3ILeBbQgbbK6elMjAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQU1m07m0jNqUMiDMb85Yzb6Pl5VAAwDQYJKoZIhvcNAQEBBQAE
# ggEACg3xt68uyxg17Ihcpp1DUL1oVzBgyUitptT2d76a4j3kQbTP+lJSce8ocFdN
# 638dHp0cJV5oTHp8y4J4I3573yP9LTHCMAEdjRlFEZUhHFjPtCr6GAVSYZzfwLSg
# vPYxL3AtAcqa8qgvvax9ijUsFrU4DrA2jxYJsg76BJeeryj/xKtG4VtYuFSQ4xfQ
# ol39g/bi+fqzWOQ1AAx8MXuDDX6fqUoc6/HK4K3MiXELAj9YOdhfYQz89gH71v4R
# N4Xu4LSUrB3ospIRk8BnXoCgKNQQiuAI+p7CRqM+9LotJ6Zo/JBFKauO4dyTs9Zi
# cHSRgKuSodKvsOAZJM6IEWr2SqGCAqIwggKeBgkqhkiG9w0BCQYxggKPMIICiwIB
# ATBoMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgw
# JgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFtcGluZyBDQSAtIEcyAhIRIQaggdM/
# 2HrlgkzBa1IJTgMwCQYFKw4DAhoFAKCB/TAYBgkqhkiG9w0BCQMxCwYJKoZIhvcN
# AQcBMBwGCSqGSIb3DQEJBTEPFw0xNTAzMTUxMTEyMTBaMCMGCSqGSIb3DQEJBDEW
# BBT7x5tyz2Mx6tyvgvL9gmrG/mSJIjCBnQYLKoZIhvcNAQkQAgwxgY0wgYowgYcw
# gYQEFLNjCLTUze1Pz71muVX647+xLCnmMGwwVqRUMFIxCzAJBgNVBAYTAkJFMRkw
# FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRp
# bWVzdGFtcGluZyBDQSAtIEcyAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJKoZIhvcN
# AQEBBQAEggEAiqFagRGHO5Ace6lhE9am437HsQL7JPkkoRaVunc51Uwx/dtdCITP
# 1sO0SdDH6C7bUAHF1xFmyIx6CM2lFG0NdJxxX58QaXWDIigxx8kkh4zqgEOXZp67
# InXR8kRRc4sGNn1iqqQb0UyeWYAfwMm4cEu5QfFN3iAbRimPsO6XCOAdUXsSpKdG
# fMVPM5WchZgRh5crAxK5fx28+3pg5RGuSGnvae3FafcvcnKNWDndxl+H06eHW1xh
# np8lumzbmHNBQAqQ4svDMU1ZizHo6wRhLDwd9PXxSJoe4snqDBg8dE/Bw89pp18D
# DKTWRkCALMyM8If51eId0EIZaNO46aM3qg==
# SIG # End signature block
