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
			if( $h.relatedLinks -And $h.relatedLinks.navigationLink -And (0 -lt $h.relatedLinks.navigationLink.Count) )
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
		if($PSBoundParameters.ContainsKey('Examples')) 
		{
			if( $h.Examples -And $h.Examples.Example )
			{
				if( $h.Examples.Example -is [Array] -And ($ExamplesMinimum -le $h.Examples.Example.Count))
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
		if($PSBoundParameters.ContainsKey('Parameters')) 
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

<#
2014-11-16; rrink; CHG: pipeline handling, Export-ModuleMember invocation only from module, coding style is now Allman
#>

# SIG # Begin signature block
# MIIW3AYJKoZIhvcNAQcCoIIWzTCCFskCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGayBWNbP1pms3TEgo1wbmd1J
# NqKgghGYMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# AQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTGElCHbUUjSgz5jnS6
# ejNRZ+uHHDANBgkqhkiG9w0BAQEFAASCAQASxJTa+JVbBYur5EK/jPU2rOvWgXWl
# 9fU+jVhpcsUgxhohLS1okqRAzNSl6ef8ydqNX2eztm0Hc5QDp8CsJkf0oF6v8Sb/
# OKtDgscUl1EjdY3xwy9aBurc18XiEVnwKkaGQT0QvcE6Xy/gbTdV/dqGXnybfX4X
# nJ0ezwG5L7jktg2G+1ZBsiyrOYLgWE3j1ytblXZhgCfssKyafzpSVJPsX3iC0FYr
# Nm2KSFWK/pMRoSPYb2qBobqbuZCj0mVJmtjSMnlLSiABDNcyPuXc5yMIauUn5Zwg
# z2LHywOt6ysuFwqrgLr6Wz39bQrHgF+vIau+mKLQx9MOEeuGzKyvlJVsoYICojCC
# Ap4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAXBgNV
# BAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0
# YW1waW5nIENBIC0gRzICEhEhQFwfDtJYiCvlTYaGuhHqRTAJBgUrDgMCGgUAoIH9
# MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MTEy
# OTE1MTI0NlowIwYJKoZIhvcNAQkEMRYEFGAjnYjaherlaU8mrIvwp0/vcwsgMIGd
# BgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUjOafUBLh0aj7OV4uMeK0K947NDsw
# bDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# KDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEhQFwf
# DtJYiCvlTYaGuhHqRTANBgkqhkiG9w0BAQEFAASCAQAa2I/nZb5WlXAfij874LN5
# QUzMXtyHXTnvSBKXWudiJLK1xDNQ3GySg8WPy13o2UPLdXhU7trM3ku4znrW4u6/
# SzBfs9AZ8xydYgncC33XwkXV5IZ+aWQ1PFTWwjP6GzF0enHykYId10YuH4fbhvBf
# sVCN6cwhTWFF76mYSXot42VBPft/pMjny6O6BWk2icIp919tM9e+maUHDhm0QXwb
# QgxqaPX2nJfRF+dXnipsnCOtLjQ3q+m50/dNCPsE+3HJQo7uO96FyFDovv5WG71a
# YXATvpq0Tc34lBRX2woYSgOh1Hdokw2xE6OuQvgTX9OOtWkD59SeHBBdj++7+Dq8
# SIG # End signature block
