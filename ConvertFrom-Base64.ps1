function ConvertFrom-Base64 {
<#
.SYNOPSIS

Decodes a BASE64 encoded string.

.DESCRIPTION

Decodes a BASE64 encoded string.

Input can be either a positional or named parameters of type string or an 
array of strings. The Cmdlet accepts pipeline input.

.EXAMPLE

ConvertFrom-Base64 VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=
This is an encoded string.

Encoded string is passed as a positional parameter to the Cmdlet.


.EXAMPLE

ConvertFrom-Base64 -InputObject VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=
This is an encoded string.

Encoded string is passed as a named parameter to the Cmdlet.


.EXAMPLE

ConvertFrom-Base64 -InputObject VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=, VGhpcyBpcyBhbiBhbm90aGVyIGVuY29kZWQgc3RyaW5nLg==
This is an encoded string.
This is an another encoded string.

Encoded strings are passed as an implicit array to the Cmdlet.


.EXAMPLE

ConvertFrom-Base64 -InputObject @("VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=", "VGhpcyBpcyBhbiBhbm90aGVyIGVuY29kZWQgc3RyaW5nLg==")
This is an encoded string.
This is an another encoded string.

Encoded strings are passed as an explicit array to the Cmdlet.


.EXAMPLE

@("VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=", "VGhpcyBpcyBhbiBhbm90aGVyIGVuY29kZWQgc3RyaW5nLg==") | ConvertFrom-Base64
This is an encoded string.
This is an another encoded string.

Encoded strings are piped as an explicit array to the Cmdlet.


.EXAMPLE

"VGhpcyBpcyBhbiBhbm90aGVyIGVuY29kZWQgc3RyaW5nLg==" | ConvertFrom-Base64
This is an another encoded string.

Encoded string is piped to the Cmdlet.


.EXAMPLE

$r = @("VGhpcyBpcyBhbiBlbmNvZGVkIHN0cmluZy4=", 0, "VGhpcyBpcyBhbiBhbm90aGVyIGVuY29kZWQgc3RyaW5nLg==") | ConvertFrom-Base64
Exception calling "FromBase64String" with "1" argument(s): "Invalid length for a Base-64 char array or string."
At C:\PSModules\biz.dfch.PS.System.Utilities\ConvertFrom-Base64.ps1:45 char:3
+         $OutputParameter = [System.Text.Encoding]::UTF8.GetString([System.Convert]::Fr ...
+    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : FormatException

$r
This is an encoded string.
This is an another encoded string.

In case one of the passed strings is not a valid BASE64 encoded string, an 
exception is thrown. The pipeline will continue to execute and all valid 
strings are returned.


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-Base64/



.NOTES

See module manifest for required software versions and dependencies at: http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


#>

[CmdletBinding(
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-Base64/'
)]
[OutputType([string])]

PARAM
(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
	$InputObject
)

BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. InputObject.Count: '{0}'" -f $InputObject.Count) -fac 1;
}

PROCESS 
{
	foreach($Object in $InputObject) 
	{
		$fReturn = $false;
		$OutputParameter = $null;

		$OutputParameter = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Object.ToString()));
		$OutputParameter;
	}
	$fReturn = $true;
}

END 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}

} # function
if($MyInvocation.ScriptName) { Export-ModuleMember -Function ConvertFrom-Base64; } 

<#
2014-11-16; rrink; CHG: pipeline handling, Export-ModuleMember invocation only from module, coding style is now Allman
#>

# SIG # Begin signature block
# MIIcVwYJKoZIhvcNAQcCoIIcSDCCHEQCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmL2VkpGLXDQbA+Z6n6AgNzsY
# 3umgghcbMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# nq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0SCjyVwk92xgNxYFwITJuNQIto4zCC
# BX8wggNnoAMCAQICCmELf2sAAAAAABkwDQYJKoZIhvcNAQEFBQAwfzELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEpMCcGA1UEAxMgTWljcm9zb2Z0
# IENvZGUgVmVyaWZpY2F0aW9uIFJvb3QwHhcNMDYwNTIzMTcwMDUxWhcNMTYwNTIz
# MTcxMDUxWjBXMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1z
# YTEQMA4GA1UECxMHUm9vdCBDQTEbMBkGA1UEAxMSR2xvYmFsU2lnbiBSb290IENB
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2g7mmY3Oo+NPin778YuD
# JWvqSB/xKrC5lREEvfBj0eJnZs8c3c8bSCvujYmOmq8pgGWr6cctEsurHExwB6E9
# CjDNFY1P+N3UjFAVHO9Q7sQu9/zpUvKRfeBt1TUwjl5Dc/JB6dVq47KJOlY5OG8G
# PIhpWypNxadUuGyJzJv5PMrl/Yn1EjySeJbW3HRuk0Rh0Y3HRrJ1DoboGYrVbWzV
# eBaVounICjjr8iQTT3NUkxOFOhu8HjS1iwWMuXeLsdsfIJGrCVNukM57N3S5cEeR
# IlFjFnmusa5BJgjIGSvRRqpI1mQq14M0/ywqwWwZQ0oHhefTfPYhaO/q8lKff5OQ
# zwIDAQABo4IBIzCCAR8wEQYDVR0gBAowCDAGBgRVHSAAMDYGCSsGAQQBgjcVBwQp
# MCcGHysGAQQBgjcVCI3g0YlOhNecwweGpob7HI/Tv6YVARkCAW4CAQAwCwYDVR0P
# BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFGB7ZhpFDZfKiVAvfQTN
# NKj//P1LMB0GCSsGAQQBgjcUAgQQHg4AQwByAG8AcwBzAEMAQTAfBgNVHSMEGDAW
# gBRi+wohW39DbhHaCVRQa/XSlnHxnjBVBgNVHR8ETjBMMEqgSKBGhkRodHRwOi8v
# Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNyb3NvZnRDb2Rl
# VmVyaWZSb290LmNybDANBgkqhkiG9w0BAQUFAAOCAgEAE8VsXgd/PFf/mzFfP72V
# VCXGefksMQNNZGlLVtlbl2988/DQJGV1OGOYE3AWE/enAfHGI+CFhmwL8ICUWnXo
# fOQekrRzv8Gzp7AL0xiEy8wJo1ycTz6wOpwtG8QE75c3lm/l7LqsarPU4jzfiyXn
# rLxiRTHdpApy5Bv4eEMBzLo5FN5dkK7YWs9eykaBUTPVpg5YZ9PYZliIFpvusRrK
# rZEThCHamm4g79oAdCi6yV/zTV3D2iVpJVTqRLzDmykzHNY8lh+HgcVT1yonM9Qu
# GXwIWG3bThmZqepf85qdjFE6Wly9L6kINZtUp9s1GlIWMzQ6o4AEav20g4ytkM8M
# OmWW7DNOGCa4SbvrgZL/E00ySyPHM+e2cWsV9pyA5ry3bL5B1QM6cTMVAFB0Ow5d
# +Zaq7ZA+qxNMgJkmvDil6wI2iR22IL6DqxD4GZ7XY3nUrrEvYTb5SkuoM8cOckH5
# 8bGQfq5G7945e3WgQRRZBB1CvEeIuBMOBfod8ICN/3DGd9hL3EYOIxpy1b/e/qqu
# aVg8/FxG5NWBmotuZVl3GjKlkKa2ZJNk/QdTyaDeKK0qbMY40YHOmPVAGeksF0Ok
# Jl/TRDBT5B0CuqQKLxbdemAnUkK7rZg3KJfkuNJ5EeMQjEjVMF0KDFLe9YjqjRot
# Z8n0gBSEt4UM0WYopcZvJGExggSmMIIEogIBATBnMFExCzAJBgNVBAYTAkJFMRkw
# FwYDVQQKExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENv
# ZGVTaWduaW5nIENBIC0gRzICEhEhYHff2l3ILeBbQgbbK6elMjAJBgUrDgMCGgUA
# oHAwEAYKKwYBBAGCNwIBDDECMAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFESi
# c6TBURrLI9BSrbtft6bKyV86MA0GCSqGSIb3DQEBAQUABIIBALit2qP3Z99Yw2Ah
# qKJUX1x0Ty45D+We89kSySm2d/l3pTumLjRKAxCPYdufcvyUm9xB+pJrcmE6WiIp
# fH0k8WELLQwF/8VQ4QFyhPEV1XU+46dGoCtA1aPkJNw8524zbVSDRLIqqJWZlFHx
# 6Gq+uq9TyH5JJtui37o7tZKpVKxdYfsVx9KUxvwTusFYiSw5AfBjdCsFVwSwcANT
# pavPNWwkdqGiGolTiAuH9K+wsKJ9S3z0OWmpReLez5qKbAq3Fk0eS9m0Pz5ezGWq
# 5m3Z7eOkRJzJDSx7c2UDetNcv9ZA3fOzHFQPAT2mxmLfuDllPcYrCW8/Nq+pnPST
# QmHmHGKhggKiMIICngYJKoZIhvcNAQkGMYICjzCCAosCAQEwaDBSMQswCQYDVQQG
# EwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEoMCYGA1UEAxMfR2xvYmFs
# U2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBHMgISESFAXB8O0liIK+VNhoa6EepFMAkG
# BSsOAwIaBQCggf0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
# CQUxDxcNMTQxMTE2MTczMjQ5WjAjBgkqhkiG9w0BCQQxFgQUumus+dKlCorqjkxg
# pZx6TpYpQY4wgZ0GCyqGSIb3DQEJEAIMMYGNMIGKMIGHMIGEBBSM5p9QEuHRqPs5
# Xi4x4rQr3js0OzBsMFakVDBSMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFs
# U2lnbiBudi1zYTEoMCYGA1UEAxMfR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0Eg
# LSBHMgISESFAXB8O0liIK+VNhoa6EepFMA0GCSqGSIb3DQEBAQUABIIBAFzWW1Eq
# BMvrgzghTh9pCJ2MiLchb25Vgt38cLMDf29nxBokQ/PCRFnostTGtZ79GokwlBqM
# X1NcQRyJkbDjLPFN2c+dapl2FJWUdx2vkn4ffhwdfRe+A2KUnEsu4WFvwhFKE9Dw
# l/SMLLKEgPfO41Pp01kkrgaYlE/ZMNexGsZSXpCjP04JEtnoyRdAL1S7ZP8j0tmP
# Fu5Iyk1elhYvXTr/Jeq9S/c+TRw5m3ohCbdMuoQXmPObYXsYGxBTIIkVWCj3ncAs
# JJ3FOxt8ydvNkeM1w5zM/8G8UDFr++sn9x+fR9wpWcDzKGdpbQoR/bXY4IFncnYv
# wAvhL4KQGv/p/Uw=
# SIG # End signature block
