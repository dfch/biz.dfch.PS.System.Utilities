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

