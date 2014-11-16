Function ConvertTo-Base64 {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertTo-Base64/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $false, Position=0)]
	    [string]

	    $InputObject
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. Length: '{0}'; NonAlpha: '{1}'" -f $Length, $NonAlpha) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$bytes  = [System.Text.Encoding]::UTF8.GetBytes($InputObject);
	$encoded = [System.Convert]::ToBase64String($bytes); 

	$OutputParameter = $encoded;
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	} # END
} # ConvertTo-Base64
Export-ModuleMember -Function ConvertTo-Base64;

