function Remove-ActivityProgress {
[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Low",
	HelpURI='http://dfch.biz/biz/dfch/PSSystem/Utilities/Remove-ActivityProgress/'
)]
Param (
	[Parameter(Mandatory = $false)]
	[switch] $ReturnDetails = $false
) # Param

BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	# Log-Debug -fn $fn -msg ('CALL. ActivityStack.Count {0}' -f $biz_dfch_PS_System_Utilities.ActivityStack.Count) -fac 1;
} # BEGIN

PROCESS {

[Boolean] $fReturn = $false;
$OutputParameter = $null;
try {

	# Parameter validation
	if($biz_dfch_PS_System_Utilities.ActivityStack.Count -le 0) {
		$msg = ('ActivityStack contains no activity that could be removed. Aborting ...');
		$e = New-CustomErrorRecord -m $msg -cat InvalidOperation -o $biz_dfch_PS_System_Utilities.ActivityStack;
		Log-Critical $fn $msg;
		throw($gotoError);
	} # if

	$act = $biz_dfch_PS_System_Utilities.ActivityStack.Peek();
	if(!$PSCmdlet.ShouldProcess($act.Activity)) {
		$fReturn = $false;
	} else {
		Write-Progress -Activity $act.Activity -Completed;
		$null = $biz_dfch_PS_System_Utilities.ActivityStack.Pop();
		$fReturn = $true;
		if($ReturnDetails) {
			$OutputParameter = $act;
		} else {
			$OutputParameter = $fReturn;
		} # if
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
			Log-Critical $fn "Login to Uri '$Uri' with Username '$Username' FAILED [$_].";
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -ne $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				# N/A
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Cleanup
} # finally

} # PROCESS

END {
	$datEnd = [datetime]::Now;
	# Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	return $OutputParameter;
} # END
} # function
Export-ModuleMember -Function Remove-ActivityProgress;

