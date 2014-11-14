Function New-SecurePassword {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PSSystem/Utilities/New-SecurePassword/'
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
Export-ModuleMember -Function New-SecurePassword;

