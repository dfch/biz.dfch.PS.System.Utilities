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

