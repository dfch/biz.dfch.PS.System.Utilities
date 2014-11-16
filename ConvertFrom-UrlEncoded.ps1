Function ConvertFrom-UrlEncoded {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-UrlEncoded/'
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

	$OutputParameter = [System.Web.HttpUtility]::UrlDecode($InputObject);
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	} # END
} # ConvertFrom-UrlEncoded
Export-ModuleMember -Function ConvertFrom-UrlEncoded;

