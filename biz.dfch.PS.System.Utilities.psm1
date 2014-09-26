#========================================================================
# Created on:   2013-01-11 20:27
# Created by:   rro
# Organization: d-fens GmbH
# Filename:  		biz.dfch.PS.System.Utilities.psm1 
#========================================================================
Import-Module biz.dfch.PS.System.Logging
Set-Variable MODULE_NAME -Option 'Constant' -Value 'biz.dfch.PS.System.Utilities';
Set-Variable MODULE_URI_BASE -Option 'Constant' -Value 'http://dfch.biz/PS/System/Utilities/';

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';

# Load module configuration file
# As (Get-Module $MODULE_NAME).ModuleBase does not return the module path during 
# module load we resort to searching the whole PSModulePath. Configuration file 
# is loaded on a first match basis.
$ENV:PSModulePath.Split(';') | % { 
	[string] $ModuleDirectoryBase = Join-Path -Path $_ -ChildPath $MODULE_NAME;
	[string] $ModuleConfigFile = [string]::Format('{0}.xml', $MODULE_NAME);
	[string] $ModuleConfigurationPathAndFile = Join-Path -Path $ModuleDirectoryBase -ChildPath $ModuleConfigFile;
	if($true -eq (Test-Path -Path $ModuleConfigurationPathAndFile)) {
		if($true -ne (Test-Path variable:$($MODULE_NAME.Replace('.', '_')))) {
			Set-Variable -Name $MODULE_NAME.Replace('.', '_') -Value (Import-Clixml -Path $ModuleConfigurationPathAndFile) -Description "The array contains the public configuration properties of the module '$MODULE_NAME'.`n$MODULE_URI_BASE" ;
		} # if()
	} # if()
} # for()
if($true -ne (Test-Path variable:$($MODULE_NAME.Replace('.', '_')))) {
	Write-Error "Could not find module configuration file '$ModuleConfigFile' in 'ENV:PSModulePath'.`nAborting module import...";
	break; # Aborts loading module.
} # if()
Export-ModuleMember -Variable $MODULE_NAME.Replace('.', '_');

Function New-CustomErrorRecord {
<#

.SYNOPSIS

Creates a custom error record.



.DESCRIPTION

Creates a custom error record.



.OUTPUTS

This Cmdlet returns a [System.Management.Automation.ErrorRecord] parameter. On failure it returns $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER ExceptionString

The name of the semaphore.



.PARAMETER idError

An optional switch parameter with which to create the semaphore in the global namespace.



.PARAMETER ErrorCategory

A number of milliseconds the Cmdlet should try to acquire the resource before giving up. By default this value is -1, which describes an infinite timeout.



.PARAMETER TargetObject

An optional count of times the semaphore should have initialls free (thus initially reserving a number of instances). By default all instances are "free" and thus not reserved.



.EXAMPLE

Creates

New-CustomErrorRecord -Name "biz-dfch-MySemaphore"



.EXAMPLE

Perform a login to a StoreBox server with username and encrypted password.

New-CustomErrorRecord -UriPortal 'https://promo.ds01.swisscom.com' -Username 'PeterLustig' -Credentials [PSCredentials]



.LINK

Online Version: http://dfch.biz/PS/System/Utilities/New-CustomErrorRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
	#This function is used to create a PowerShell ErrorRecord
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/New-CustomErrorRecord/'
    )]
	[OutputType([System.Management.Automation.ErrorRecord])]
	PARAM (
		[Parameter(Mandatory = $false, Position = 0)]
		[alias("msg")]
		[alias("m")]
		[String]
		$ExceptionString = 'Unspecified CustomError encountered.'
		,
		[Parameter(Mandatory = $false, Position = 1)]
		[alias("id")]
		[String]
		$idError = 1
		,
		[Parameter(Mandatory = $false, Position = 2)]
		[alias("cat")]
		[alias("c")]
		[System.Management.Automation.ErrorCategory]
		$ErrorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified
		,
		[Parameter(Mandatory = $false, Position = 3)]
		[alias("obj")]
		[alias("o")]
		[PSObject]
		$TargetObject = $PsCmdlet
	)
	BEGIN {
		$datBegin = [datetime]::Now;
		[string] $fn = $MyInvocation.MyCommand.Name;
		Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	}
	PROCESS {
		[boolean] $fReturn = $false;

		try {
			# Parameter validation
			# N/A

			$exception = New-Object System.Management.Automation.RuntimeException($ExceptionString);
			$customError = New-Object System.Management.Automation.ErrorRecord($exception, $idError, $ErrorCategory, $TargetObject);
			$OutputParameter = $customError;
			
		} # try
		catch {
			if($gotoSuccess -eq $_.Exception.Message) {
				$fReturn = $true;
			} elseif($gotoNotFound -eq $_.Exception.Message) {
				$fReturn = $false;
				$OutputParameter = $null;
			} else {
				[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
				$ErrorText += (($_ | fl * -Force) | Out-String);
				$ErrorText += (($_.Exception | fl * -Force) | Out-String);
				$ErrorText += (Get-PSCallStack | Out-String);
				
				if($_.Exception.InnerException -is [System.Net.WebException]) {
					Log-Critical $fn "Operation '$Method' '$Api' with UriServer '$UriServer' FAILED [$_].";
					Log-Debug $fn $ErrorText -fac 3;
				} # [System.Net.WebException]
				else {
					Log-Error $fn $ErrorText -fac 3;
					if($gotoFailure -ne $_.Exception.Message) { Write-Verbose ("$fn`n$ErrorText"); }
				} # other exceptions
				$fReturn = $false;
				$OutputParameter = $null;
			} # !$gotoSuccess
		} # catch
		finally {
			# Clean up
		} # finally
		return $OutputParameter;
	} # PROCESS
	END {
		$datEnd = [datetime]::Now;
		Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # New-CustomErrorRecord
Set-Alias -Name ex -Value New-CustomErrorRecord;
Set-Alias -Name New-Exception -Value New-CustomErrorRecord;
Export-ModuleMember -Function New-CustomErrorRecord -Alias New-Exception, ex;


# http://blogs.technet.com/b/jamesone/archive/2010/01/19/how-to-pretty-print-xml-from-powershell-and-output-utf-ansi-and-other-non-unicode-formats.aspx
function Format-Xml {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/Format-Xml/'
    )]
	[OutputType([string])]
	PARAM (
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'file')]
		$File
		,
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0, ParameterSetName = 'string')]
		$String
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	#Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	}
	PROCESS {
	$doc = New-Object System.Xml.XmlDataDocument;
	switch ($PsCmdlet.ParameterSetName) {
    "file"  { 
		$fReturn = Test-Path $File -ErrorAction:SilentlyContinue;
		if($fReturn) {
			$doc.Load((Resolve-Path $File));
		} else {
			$doc.LoadXml($File)
		} # if
	}
    "string"  {
		$doc.LoadXml($String)
	}
	} # switch
	$sw = New-Object System.IO.StringWriter;
	$writer = New-Object System.Xml.XmlTextWriter($sw);
	$writer.Formatting = [System.Xml.Formatting]::Indented;
	$doc.WriteContentTo($writer);
	$doc = 
	return $sw.ToString();
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	#Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # Format-Xml
Set-Alias -Name fx -Value Format-Xml;
Export-ModuleMember -Function Format-Xml -Alias fx;

function ConvertFrom-UnicodeHexEncoding {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertFrom-UnicodeHexEncoding/'
    )]
	[OutputType([string])]
	PARAM (
		[Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $true, Position = 0)]
		[String]
		$string
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	} # BEGIN
	PROCESS {
	if($string -match "^X''*") {
		$Convert = $string.replace("X'","");
		$Convert = $Convert.replace("'","");
		$string = [System.Text.UTF8Encoding]::UTF8.GetString( ( $Convert  -split '(..)' | ? { $_ } |  %  {[Byte]( [Convert]::ToInt16($_, 16))  } ) );
	} # if
	return $string; 
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # ConvertFrom-UnicodeHexEncoding
Set-Alias -Name ConvertFrom-ExchangeEncoding -Value ConvertFrom-UnicodeHexEncoding;
Export-ModuleMember -Function ConvertFrom-UnicodeHexEncoding -Alias ConvertFrom-ExchangeEncoding;

function ConvertFrom-SecureStringDF {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertFrom-SecureString/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position=0)]
	    [System.Security.SecureString]
	    $Input
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	} # BEGIN
	PROCESS {
	$marshal = [System.Runtime.InteropServices.Marshal];
	$ptr = $marshal::SecureStringToBSTR( $Input );
	$str = $marshal::PtrToStringBSTR( $ptr );
	$marshal::ZeroFreeBSTR( $ptr );
	return $Input;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # function
Export-ModuleMember -Function ConvertFrom-SecureStringDF;


Function New-SecurePassword {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/New-SecurePassword/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(Mandatory = $false, Position=0)]
	    [int]
	    $Length = 8
		,
	    [Parameter(Mandatory = $false, Position=1)]
	    [int]
	    $NonAlpha = 2
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length: '{0}'; NonAlpha: '{1}'" -f $Length, $NonAlpha) -fac 1;
	} # BEGIN
	PROCESS {
	$CharSetAlpha           = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	$CharSetNonAlpha        = "!@#$%^&*()_-+=[{]};:<>|./?";
	$CharSetNonAlphaReduced = "!@#$*()_-+=[{]};:./?";
	$CharSetAlphaReduced    = "abcdefghijkmnopqrstuvwxyzACDEFGHJKLMNPQRTUVWXYZ0123456789";
	$CharSetFullReduced	    = '{0}{1}' -f $CharSetNonAlphaReduced, $CharSetAlphaReduced;
	$CharSetAlphaUpper      = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	$CharSetAlphaLower      = 'abcdefghijklmnopqrstuvwxyz';
	$CharSetDigits          = '0123456789';
	
	do {
		Log-Debug $fn "Generating password ...";
		$a = Get-Random -Count ($Length - $NonAlpha) -InputObject $CharSetAlphaReduced.ToCharArray();
		$password = [string]::Join('', $a)
		$nUpper = $password.IndexOfAny($CharSetAlphaUpper.ToCharArray());
		$nLower = $password.IndexOfAny($CharSetAlphaLower.ToCharArray());
		$nDigits = $password.IndexOfAny($CharSetDigits.ToCharArray());
	} while( ($nUpper -eq -1) -or ($nLower -eq -1) -or ($nDigits -eq -1) );
	if($NonAlpha -gt 0) {
		$a = Get-Random -Count $NonAlpha -InputObject $CharSetNonAlphaReduced.ToCharArray();
		$password = '{0}{1}' -f $password, [string]::Join('', $a)
	} # if
	if($password.Length -gt 1) {
		$passwordMixed = '';
		$l = $password.Length -1;
		 1..$l | % {
			$c = Get-Random -Minimum 0 -Maximum ($password.Length -1);
			$passwordMixed = '{0}{1}' -f $passwordMixed, $password[$c]; 
			$password = $password.Remove($c,1);
		 } # %
		 $passwordMixed = '{0}{1}' -f $passwordMixed, $password[0]; 
		 $password = $passwordMixed;
	} # if
	Log-Debug $fn "Generating password COMPLETED.";

	return $password;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # New-SecurePassword
Set-Alias -Name New-Password -Value New-SecurePassword;
Export-ModuleMember -Function New-SecurePassword;

Function ConvertTo-UrlEncoded {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertTo-UrlEncoded/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $false, Position=0)]
	    [string]
	    $Input
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length '{0}'" -f $Input.Length) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$OutputParameter = [System.Web.HttpUtility]::UrlEncode($Input);
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # ConvertTo-UrlEncoded
Export-ModuleMember -Function ConvertTo-UrlEncoded;

Function ConvertFrom-UrlEncoded {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertFrom-UrlEncoded/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $false, Position=0)]
	    [string]
	    $Input
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length: '{0}'; NonAlpha: '{1}'" -f $Length, $NonAlpha) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$OutputParameter = [System.Web.HttpUtility]::UrlDecode($Input);
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # ConvertFrom-UrlEncoded
Export-ModuleMember -Function ConvertFrom-UrlEncoded;

Function ConvertTo-Base64 {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertTo-Base64/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $false, Position=0)]
	    [string]
	    $Input
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length: '{0}'; NonAlpha: '{1}'" -f $Length, $NonAlpha) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$bytes  = [System.Text.Encoding]::UTF8.GetBytes($Input);
	$encoded = [System.Convert]::ToBase64String($bytes); 

	$OutputParameter = $encoded;
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # ConvertTo-Base64
Export-ModuleMember -Function ConvertTo-Base64;

Function ConvertFrom-Base64 {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertFrom-Base64/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $false, Position=0)]
	    [string]
	    $Input
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length: '{0}'; NonAlpha: '{1}'" -f $Length, $NonAlpha) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$bytes  = [System.Convert]::FromBase64String($Input);
	$decoded = [System.Text.Encoding]::UTF8.GetString($bytes);

	$OutputParameter = $decoded;
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # ConvertFrom-Base64
Export-ModuleMember -Function ConvertFrom-Base64;

function Get-ComObjectType {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/Get-ComObjectType/'
    )]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $true, Position=0)]
		[ref] 
		$InputObject
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. InputObject: '{0}'" -f $InputObject) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$TypeName = $null;
	#$InputObject | gm;
	$v = $InputObject.Value;
	#$v.GetType();
	$fReturn = $false;
	foreach($PSTypeName in $v.pstypenames) {
		#$PSTypeName
		#$PSTypeName.GetType();
		$Matches = $null;
		$fReturn = $PSTypeName -match '^System.__ComObject#({.+})$';
		if($fReturn) { break; }
	} #foreach
	if(!$fReturn) {
		Log-Error $fn ("InputObject is not a ComObject: '{0}'" -f $InputObject.GetType());
		$OutputParameter = $null;
	} else {
		$Type = $Matches[1];
		$TypeName = (Get-ItemProperty "HKLM:\SOFTWARE\Classes\Interface\$type").'(default)';
		Log-Debug $fn ("InputObject resolved to type: '{0}'" -f $TypeName);
		$OutputParameter = $TypeName;
	} # if
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # Get-ComObjectType
Export-ModuleMember -Function Get-ComObjectType;

function Test-StringPattern {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/Get-ComObjectType/'
    )]
PARAM (
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
	$InputObject
	,
	[Parameter(Mandatory=$false,ParameterSetName='guid')]
	[switch] $Guid
	,
	[Parameter(Mandatory=$false,ParameterSetName='urn')]
	[switch] $Urn
	,
	[ValidateSet('guid', 'urn', 'hp', 'hp4345', 'hp3027', 'lx544', 'scan')]
	[Parameter(Mandatory=$false,ParameterSetName='type')]
	[string] $Type
	,
	[Parameter(Mandatory=$false)]
	[switch] $Extract = $false
)

[string] $fn = $MyInvocation.MyCommand.Name;
#Write-Host $PSCmdlet.ParameterSetName
$fReturn = $false;
$OutputParameter = $null;
$Matches = $null;

#$InputObject = 'urn:vcloud:vcd:559ccf96-1cc5-4f79-ba4e-69dd1fa66fab';
switch($PSCmdlet.ParameterSetName) {
'guid' {
	$Pattern = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
	$fReturn = $InputObject -match $Pattern;
}
'urn' {
	$Pattern = '(urn:vcloud:[^:]+):([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})';
	$fReturn = $InputObject -match $Pattern;
}
'type' {
	switch($Type) {
	'hp' {
		$Pattern = '^(?<Name>doc-?[^_]*)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		#if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'hp4345' {
		$Pattern = '^(?<Name>doc-?[^_]*)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		#if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'hp3027' {
		$Pattern = '^(?<Name>\[[^\-_]+-?)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'lx544' {
		$Pattern = '^(?<Name>doc)-(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})_(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'scan' {
		$Pattern = '^(?<Name>doc)---(?<Year>\d{4})-(?<Month>\d{2})-(?<Day>\d{2})---(?<Hour>\d{2})-(?<Minute>\d{2})-(?<Second>\d{2})---(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	default {
		$e = New-CustomErrorRecord -m ("Cannot validate argument on parameter 'Type': '{0}'. Aborting ..." -f $Type) -cat InvalidData -o $Type;
		Log-Error $fn $e.Exception.Message;
		$PSCmdlet.ThrowTerminatingError($e);
	}
	} # switch
}
default {
	$e = New-CustomErrorRecord -m ("A parameter cannot be found that matches parameter name 'PSCmdlet.ParameterSetName': '{0}'. Aborting ..." -f $PSCmdlet.ParameterSetName) -cat InvalidArgument -o $PSCmdlet.ParameterSetName;
	Log-Error $fn $e.Exception.Message;
	$PSCmdlet.ThrowTerminatingError($e);
}
} # switch

if($Extract -and $fReturn) { 
	$OutputParameter = $Matches; 
} else {
	$OutputParameter = $fReturn; 
} #  if
return $OutputParameter;

} # Test-StringPattern
Export-ModuleMember -Function Test-StringPattern;

function Import-Credential{
	[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Low",
	HelpURI='http://dfch.biz/PS/System/Utilities/Export-Credential/'
    )]
Param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $True, Position = 0)]
	[string] $Path
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $KeyPhrase = [NullString]::Value
	)

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Path '{0}'. KeyPhrase.Count '{1}'." -f $Path, $KeyPhrase.Count) -fac 1;
# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;
try {

	# Parameter validation
	# N/A
	if($PSCmdlet.ShouldProcess($Path)) {
		$Credential = Import-CliXml $Path;
		if($KeyPhrase) {
			$KeyPhrase = $KeyPhrase.PadRight(32, '0').Substring(0, 32);
			$Enc = [System.Text.Encoding]::UTF8;
			$k = $Enc.GetBytes($KeyPhrase);
			
			$Credential.Password = $Credential.Password | ConvertTo-SecureString -Key $k;
			$Credential = New-Object System.Management.Automation.PSCredential($Credential.Username, $Credential.Password);
		} else {
			$Credential = Import-CliXml $Path;
		} # if
		$fReturn = $true;
		$OutputParameter = $Credential;
	} # if

} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -eq $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				throw($_);
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up

	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
} # finally
return $OutputParameter;

} # Import-Credential
Export-ModuleMember -Function Import-Credential;

function Export-Credential{
	[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Low",
	HelpURI='http://dfch.biz/PS/System/Utilities/Export-Credential/'
    )]
Param(
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Path
	,
	[Parameter(Mandatory = $true, ValueFromPipeline = $True, Position = 1)]
	[Alias('Credential')]
	[PSCredential] $InputObject
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $KeyPhrase = [NullString]::Value
	)

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Path '{0}'. KeyPhrase.Count '{1}'." -f $Path, $KeyPhrase.Count) -fac 1;
# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;
try {

	# Parameter validation
	# N/A
	if($KeyPhrase) {
		Log-Debug $fn ("Creating KeyPattern from Keyphrase ...");
		$KeyPhrase = $KeyPhrase.PadRight(32, '0').Substring(0, 32);
		$Enc = [System.Text.Encoding]::UTF8;
		$k = $Enc.GetBytes($KeyPhrase);
		
		Log-Debug $fn ("Encrypting password  ...");
		$Cred = Select-Object -Property '*' -InputObject $InputObject;
		$Cred.Password = ConvertFrom-SecureString -SecureString $Cred.Password -Key $k;
	} else {
		$Cred = $InputObject;
	} # if
	if($PSCmdlet.ShouldProcess( ("Cred.Username '{0}' to '{1}'" -f $Cred.Username, $Path) )) {
		Log-Debug $fn ("Saving PSCredential ...");
		$OutputParameter = Export-CliXml -Path $Path -InputObject $Cred -WhatIf:$false -Confirm:$false;
		$fReturn = $true;
	} # if
	
} # try
catch {
	if($gotoSuccess -eq $_.Exception.Message) {
		$fReturn = $true;
	} else {
		[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
		$ErrorText += (($_ | fl * -Force) | Out-String);
		$ErrorText += (($_.Exception | fl * -Force) | Out-String);
		$ErrorText += (Get-PSCallStack | Out-String);
		
		if($_.Exception -is [System.Net.WebException]) {
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -eq $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				throw($_);
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up

	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
} # finally
return $OutputParameter;

} # Export-Credential
Export-ModuleMember -Function Export-Credential;

function get-Constructor ([type]$type, [Switch]$FullName) {
    foreach ($c in $type.GetConstructors()) {
        $type.Name + "("
        foreach ($p in $c.GetParameters()) {
             if ($fullName) {
                  "`t{0} {1}," -f $p.ParameterType.FullName, $p.Name 
             } else {
                  "`t{0} {1}," -f $p.ParameterType.Name, $p.Name 
             } # if
        } # foreach
        ")"
    } # foreach
} # Get-Constructor
Export-ModuleMember -Function Get-Constructor;

function Set-SslSecurityPolicy {
	[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="High",
	HelpURI='http://dfch.biz/PS/System/Utilities/Set-SslSecurityPolicy/'
    )]
Param(
	[Parameter(Mandatory = $false, Position = 0)]
	[switch] $TrustAllCertificates = $true
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[switch] $CheckCertificateRevocationList = $false
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[switch] $ServerCertificateValidationCallback = $true
	)

	if($PSCmdlet.ShouldProcess("")) {
	
		if($TrustAllCertificates) {
Add-Type @"
	using System.Net;
	using System.Security.Cryptography.X509Certificates;
	public class TrustAllCertsPolicy : ICertificatePolicy {
	   public bool CheckValidationResult(
			ServicePoint srvPoint, X509Certificate certificate,
			WebRequest request, int certificateProblem) {
			return true;
		}
	}
"@
			[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;
		} # if
		if(!$CheckCertificateRevocationList) {
			[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false;
		} # if
		if($ServerCertificateValidationCallback) {
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true; };
		} #if
	} # if

} # Set-SslSecurityPolicy
Export-ModuleMember -Function Set-SslSecurityPolicy;

<#
 # ########################################
 # Version history
 # ########################################
 #
 # 2013-10-27; rrink; ADD: Set-SslSecurityPolicy
 # 2013-10-27; rrink; ADD: Get-Constructor
 # 2013-10-24; rrink; ADD: Export-Credential, rewrite to accept pipeline input
 # 2013-10-24; rrink; ADD: Import-Credential, rewrite to accept pipeline input
 # 2013-01-11; rrink; ADD: initial release
 #
 # ########################################
 #>
