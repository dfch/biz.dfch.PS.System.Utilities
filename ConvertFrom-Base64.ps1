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
# MIILewYJKoZIhvcNAQcCoIILbDCCC2gCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmL2VkpGLXDQbA+Z6n6AgNzsY
# 3umgggjdMIIEKDCCAxCgAwIBAgILBAAAAAABL07hNVwwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0xOTA0MTMxMDAwMDBaMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWdu
# aW5nIENBIC0gRzIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyTxTn
# EL7XJnKrNpfvU79ChF5Y0Yoo/ENGb34oRFALdV0A1zwKRJ4gaqT3RUo3YKNuPxL6
# bfq2RsNqo7gMJygCVyjRUPdhOVW4w+ElhlI8vwUd17Oa+JokMUnVoqni05GrPjxz
# 7/Yp8cg10DB7f06SpQaPh+LO9cFjZqwYaSrBXrta6G6V/zuAYp2Zx8cvZtX9YhqC
# VVrG+kB3jskwPBvw8jW4bFmc/enWyrRAHvcEytFnqXTjpQhU2YM1O46MIwx1tt6G
# Sp4aPgpQSTic0qiQv5j6yIwrJxF+KvvO3qmuOJMi+qbs+1xhdsNE1swMfi9tBoCi
# dEC7tx/0O9dzVB/zAgMBAAGjgfowgfcwDgYDVR0PAQH/BAQDAgEGMBIGA1UdEwEB
# /wQIMAYBAf8CAQAwHQYDVR0OBBYEFAhu2Lacir/tPtfDdF3MgB+oL1B6MEcGA1Ud
# IARAMD4wPAYEVR0gADA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxz
# aWduLmNvbS9yZXBvc2l0b3J5LzAzBgNVHR8ELDAqMCigJqAkhiJodHRwOi8vY3Js
# Lmdsb2JhbHNpZ24ubmV0L3Jvb3QuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB8G
# A1UdIwQYMBaAFGB7ZhpFDZfKiVAvfQTNNKj//P1LMA0GCSqGSIb3DQEBBQUAA4IB
# AQAiXMXdPfQLcNjj9efFjgkBu7GWNlxaB63HqERJUSV6rg2kGTuSnM+5Qia7O2yX
# 58fOEW1okdqNbfFTTVQ4jGHzyIJ2ab6BMgsxw2zJniAKWC/wSP5+SAeq10NYlHNU
# BDGpeA07jLBwwT1+170vKsPi9Y8MkNxrpci+aF5dbfh40r5JlR4VeAiR+zTIvoSt
# vODG3Rjb88rwe8IUPBi4A7qVPiEeP2Bpen9qA56NSvnwKCwwhF7sJnJCsW3LZMMS
# jNaES2dBfLEDF3gJ462otpYtpH6AA0+I98FrWkYVzSwZi9hwnOUtSYhgcqikGVJw
# Q17a1kYDsGgOJO9K9gslJO8kMIIErTCCA5WgAwIBAgISESFgd9/aXcgt4FtCBtsr
# p6UyMA0GCSqGSIb3DQEBBQUAMFExCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9i
# YWxTaWduIG52LXNhMScwJQYDVQQDEx5HbG9iYWxTaWduIENvZGVTaWduaW5nIENB
# IC0gRzIwHhcNMTIwNjA4MDcyNDExWhcNMTUwNzEyMTAzNDA0WjB6MQswCQYDVQQG
# EwJERTEbMBkGA1UECBMSU2NobGVzd2lnLUhvbHN0ZWluMRAwDgYDVQQHEwdJdHpl
# aG9lMR0wGwYDVQQKDBRkLWZlbnMgR21iSCAmIENvLiBLRzEdMBsGA1UEAwwUZC1m
# ZW5zIEdtYkggJiBDby4gS0cwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDTG4okWyOURuYYwTbGGokj+lvBgo0dwNYJe7HZ9wrDUUB+MsPTTZL82O2INMHp
# Q8/QEMs87aalzHz2wtYN1dUIBUaedV7TZVme4ycjCfi5rlL+p44/vhNVnd1IbF/p
# xu7yOwkAwn/iR+FWbfAyFoCThJYk9agPV0CzzFFBLcEtErPJIvrHq94tbRJTqH9s
# ypQfrEToe5kBWkDYfid7U0rUkH/mbff/Tv87fd0mJkCfOL6H7/qCiYF20R23Kyw7
# D2f2hy9zTcdgzKVSPw41WTsQtB3i05qwEZ3QCgunKfDSCtldL7HTdW+cfXQ2IHIt
# N6zHpUAYxWwoyWLOcWcS69InAgMBAAGjggFUMIIBUDAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzA+BgNVHR8ENzA1MDOgMaAvhi1odHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25nMi5jcmwwUAYIKwYBBQUHAQEERDBCMEAG
# CCsGAQUFBzAChjRodHRwOi8vc2VjdXJlLmdsb2JhbHNpZ24uY29tL2NhY2VydC9n
# c2NvZGVzaWduZzIuY3J0MB0GA1UdDgQWBBTwJ4K6WNfB5ea1nIQDH5+tzfFAujAf
# BgNVHSMEGDAWgBQIbti2nIq/7T7Xw3RdzIAfqC9QejANBgkqhkiG9w0BAQUFAAOC
# AQEAB3ZotjKh87o7xxzmXjgiYxHl+L9tmF9nuj/SSXfDEXmnhGzkl1fHREpyXSVg
# BHZAXqPKnlmAMAWj0+Tm5yATKvV682HlCQi+nZjG3tIhuTUbLdu35bss50U44zND
# qr+4wEPwzuFMUnYF2hFbYzxZMEAXVlnaj+CqtMF6P/SZNxFvaAgnEY1QvIXI2pYV
# z3RhD4VdDPmMFv0P9iQ+npC1pmNLmCaG7zpffUFvZDuX6xUlzvOi0nrTo9M5F2w7
# LbWSzZXedam6DMG0nR1Xcx0qy9wYnq4NsytwPbUy+apmZVSalSvldiNDAfmdKP0S
# CjyVwk92xgNxYFwITJuNQIto4zGCAggwggIEAgEBMGcwUTELMAkGA1UEBhMCQkUx
# GTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExJzAlBgNVBAMTHkdsb2JhbFNpZ24g
# Q29kZVNpZ25pbmcgQ0EgLSBHMgISESFgd9/aXcgt4FtCBtsrp6UyMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBREonOkwVEayyPQUq27X7emyslfOjANBgkqhkiG9w0BAQEFAASCAQCh
# sew3snZtCQCrF9wesPs0iYV7WFSjLq8nv0MBnd2f/jCnbxYpeKPFkfgjB8sdjwWe
# g6EgteBrnjEXisDjMgGWYuOBvGTruJBSdJBYyh+YGX/FRACsAqFTlh/rawhAwilx
# S3AntzCGmwQj0FQ7iXtj/U7GnwRR+LLlYfRLjh2LQtL7c1n30kPBUFEEyn3l1vcU
# zHZUIY0nu5seG4mOZmaC/nG3p9B5iUZ9E4zcucRiuw25trvHS9aAEOUAstUcLDYM
# 32Cgy7o98OsU6mU2DR5vGU5+Z55MI6ujgk8lm+e+2DwdCEIP0TCXRFnQlQ6EWAk6
# xsN+bbjA/Z1uZDCdhgcw
# SIG # End signature block
