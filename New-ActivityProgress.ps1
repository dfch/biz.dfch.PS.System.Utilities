function New-ActivityProgress {
[CmdletBinding(
	HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/New-ActivityProgress/'
)]
[OutputType([Int])]
Param (
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $Activity = $MyInvocation.MyCommand.Name
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $Status
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $CurrentOperation
	,
	[ValidateRange(0,[long]::MaxValue)]
	[Parameter(Mandatory = $false, Position = 3)]
	[long] $CurrentItem = 0
	,
	[Parameter(Mandatory = $false, Position = 4)]
	[Alias('Items')]
	[long] $MaxItems = 100
	,
	[ValidateRange(-1,[int]::MaxValue)]
	[Parameter(Mandatory = $false)]
	[int] $ParentID = -1
	,
	[Parameter(Mandatory = $false)]
	[datetime] $Begin = [datetime]::Now
	,
	[Parameter(Mandatory = $false)]
	[switch] $ShowTimeRemaining = $false
	,
	[Parameter(Mandatory = $false)]
	[switch] $Show = $true
	,
	[Parameter(Mandatory = $false)]
	[switch] $AutoRemove = $true
) # Param


BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	# Log-Debug -fn $fn -msg ('CALL.') -fac 1;

} # BEGIN

PROCESS {

[Boolean] $fReturn = $false;
$OutputParameter = $null;
try {

	$act = @{};
	$act.Activity = $Activity;
	$act.Status = $Status;
	$act.CurrentOperation = $CurrentOperation;
	$act.CurrentItem = $CurrentItem;
	$act.MaxItems = $MaxItems;
	$act.ParentID = $ParentID;
	$act.ShowTimeRemaining = $ShowTimeRemaining;
	$act.Begin = $Begin;
	$act.AutoRemove = $AutoRemove;
	$biz_dfch_PS_System_Utilities.ActivityStack.Push($act);
	
	$fReturn = $true;
	if($Show) { $null = Set-ActivityProgress; }
	$OutputParameter = $biz_dfch_PS_System_Utilities.ActivityStack.Count;

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
Export-ModuleMember -Function New-ActivityProgress;

