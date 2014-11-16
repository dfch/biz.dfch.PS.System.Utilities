function ConvertFrom-Base64 
{
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
