function ConvertFrom-SecureStringDF {
	[CmdletBinding(
		HelpURI='http://dfch.biz/PS/System/Utilities/ConvertFrom-SecureString/'
    )]
	[OutputType([string])]
	PARAM(
	    [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position=0)]
	    [System.Security.SecureString]
	    $InputObject
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	} # BEGIN
	PROCESS {
	$marshal = [System.Runtime.InteropServices.Marshal];
	$ptr = $marshal::SecureStringToBSTR( $InputObject );
	$str = $marshal::PtrToStringBSTR( $ptr );
	$marshal::ZeroFreeBSTR( $ptr );
	return $InputObject;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg "RET. fReturn: [$fReturn]. Execution time: [$(($datEnd - $datBegin).TotalMilliseconds)]ms. Started: [$($datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz'))]." -fac 2;
	} # END
} # function
Export-ModuleMember -Function ConvertFrom-SecureStringDF;
