function Send-ShortMessage {
<#
.SYNOPSIS

Sends a short message (SMS) to a Short Message Provider

.DESCRIPTION

Sends a short message (SMS) to a Short Message Provider

Multiple numbers can be piped to the Cmdlet. Numbers must be in international 
format (only numbers, no leading zero, '+', space or '-').
Currently 'Clickatell' is the only supported provider.

.EXAMPLE
Send-ShortMessage 41995551234 'hello, world!' e2c479178dd741aabe4d05c25db9b9b3
Name                           Value
----                           -----
apiMessageId                   2249157aa12e410398ce8e72f6108a36
accepted                       True
to                             41995551234

Send an SMS to '41995551234' (Switzerland) with the message text 'hello, world!' 
and the authentication token 'e2c479178dd741aabe4d05c25db9b9b3'.

=== HTTP REQUEST ===
POST https://api.clickatell.com/rest/message HTTP/1.1
Authorization: Bearer e2c479178dd741aabe4d05c25db9b9b3
X-Version: 1
User-Agent: Mozilla/5.0 (Windows NT; Windows NT 6.1; en-US) WindowsPowerShell/3.0
Content-Type: application/json
Host: api.clickatell.com
Content-Length: 46

{"text":"'hello, world!","to":["41995551234"]}

=== HTTP RESPONSE ===
HTTP/1.1 202 Accepted
Date: Mon, 16 Feb 2015 07:35:05 GMT
Server: Apache
Content-Length: 109
Content-Type: application/json

{"data":{"message":[{"accepted":true,"to":"41995551234","apiMessageId":"2249157aa12e410398ce8e72f6108a36"}]}}

.EXAMPLE
'41995551234',41995551235' | Send-ShortMessage -Message 'hello, world!' e2c479178dd741aabe4d05c25db9b9b3

Send an SMS to '41995551234' and '41995551235' with the message text 'hello, world!' 
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
	# Specfies the message
	[Parameter(Mandatory = $true, Position = 1)]
	[alias("text")]
	[String] $Message
	,
	# Specifies the authenticatio token, can be either a plain string or a PSCredential object
	[Parameter(Mandatory = $true)]
	[alias("password")]
	[alias("token")]
	$Credential
	,
	# Specify the maximum credits to spend on the message
	[Parameter(Mandatory = $false)]
	[int] $MaxCredits
	,
	# Specifies the maximum parts of the message (if longer than 160 chars)
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
	}
}
PROCESS
{
	try
	{
		# Currently only clickatell is supported. If there is more than one 
		# provider in the future, this should be moved to a separate sub-function.
		$Uri = 'https://api.clickatell.com/rest/message';
		$headers = @{};
		# tricky - version must be set as string, otherwise Invoke-RestMethod call fails
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
		foreach($Object in $InputObject) 
		{
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
	# N/A
}

} # function
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Send-ShortMessage; } 

<#
2015-02-16; rrink; ADD: initial version
#>

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvchdRBqJalHfN+lkKV0kgfMy
# 0B6gghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTd7xzHnpzvROOqrFpd
# Yp0EsVKILDANBgkqhkiG9w0BAQEFAASCAQA3BdYt+hw8MK5RKifJVnU7tl9RKA9T
# +MmsxuNxG6CVTE4sYwSTqXyR3TIT0IWwQhEeHmDT8DbCWzmlbOOF8lhvm0mqdcg4
# 3SJ4iCN6IhinL3cXbnx6jhcGFMLiTwBmVFwTGjNpRdEvYmdInTYjd6ci3lRRrBHM
# UD44Nm1eSUNJjPunAmNGCVfg7iZfyWcep+jc7K93yVWAnJXpvUFBAX9Q5bdomNKo
# +y23a3MbkyTXiYBNHNFyuz6gLBeZpfkjOv1jT0m2SE1SZiOQ5AoQawsiYNSy7czn
# n/MJ49Si+TNKHGraHn10EsvNofu0SCv0J+xG73HyemEpLdVowy/LOOR1oYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1MDIy
# ODA3MzcwN1owIwYJKoZIhvcNAQkEMRYEFJ9Km3LgjTd97CFeg1mcp3wtyqZkMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQCHYWTp79pJOUcoCnXr9VfZ
# GMWgVOrwOCWXvvgFJ18WpSQ0kQbADMrbz2xlIBa5ogTp4v5z1F6WODZw+AADDqHp
# HMaFx3xpQZQUmdBXXKt9sTDEJ5g+7oTMiey3CnJl+jWUx7xlarFB6gGTCCIcitej
# TylNV0jWzzuS48RfFIfofth8oXXh2Nv1uUr5sxjVgFzyaLcuaOZ/w4fTesYhCALQ
# jitYeyLJb1ENqfXdTv7BNVvLVx6Sc2geSO13JJQTtWc5pv3d6DygPfQhcEQbV6wB
# qZDr0CjWfc076cyHmdQw0jo3K8nrQh1hkq0VywOZAFxL4fkKW2xsXdK2qhBJLgjh
# SIG # End signature block
