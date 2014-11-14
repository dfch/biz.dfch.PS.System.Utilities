function Set-ActivityProgress {
[CmdletBinding(
	HelpURI='http://dfch.biz/biz/dfch/PSSystem/Utilities/Set-ActivityProgress/'
)]
[OutputType([Boolean])]
Param (
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $Activity
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $Status
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $CurrentOperation
	,
	[ValidateRange(0,[long]::MaxValue)]
	[Parameter(Mandatory = $false, Position = 3)]
	[long] $CurrentItem
	,
	[Parameter(Mandatory = $false, Position = 4)]
	[Alias('Items')]
	[long] $MaxItems
	,
	[Parameter(Mandatory = $false)]
	[switch] $ShowTimeRemaining = $false
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

	$act = $biz_dfch_PS_System_Utilities.ActivityStack.Peek();
	if($PSBoundParameters.ContainsKey('Activity')) { $act.Activity = $Activity; }
	if($PSBoundParameters.ContainsKey('Status')) { $act.Status = $Status; }
	if($PSBoundParameters.ContainsKey('CurrentOperation')) { $act.CurrentOperation = $CurrentOperation; }
	if($PSBoundParameters.ContainsKey('CurrentItem')) { $act.CurrentItem = $CurrentItem; }
	if($PSBoundParameters.ContainsKey('MaxItems')) { $act.MaxItems = $MaxItems; }
	if($PSBoundParameters.ContainsKey('ShowTimeRemaining')) { $act.ShowTimeRemaining = $ShowTimeRemaining; }
	$null = $biz_dfch_PS_System_Utilities.ActivityStack.Pop();
	$biz_dfch_PS_System_Utilities.ActivityStack.Push($act);
	$WriteProgress = @{};
	$WriteProgress.Id = $biz_dfch_PS_System_Utilities.ActivityStack.Count;
	if($act.ParentID -eq -1) { $WriteProgress.ParentID = $WriteProgress.Id -1; }
	if($act.Activity) { $WriteProgress.Activity = $act.Activity; }
	if($act.Status) { $WriteProgress.Status = $act.Status; }
	if($act.CurrentOperation) { $WriteProgress.CurrentOperation = $act.CurrentOperation; }
	$WriteProgress.PercentComplete = ((($act.CurrentItem / [Math]::Max($act.MaxItems,1))*100)%100);
	if( ($act.ShowTimeRemaining) -And ($act.CurrentItem -gt 1) ) {
		$ts = New-Object TimeSpan(($datBegin - $act.Begin).Ticks);
		$WriteProgress.SecondsRemaining = [Math]::Min((($act.MaxItems - $act.CurrentItem) * $ts.TotalSeconds) / $act.CurrentItem, [int]::MaxValue);
	} # if
	Write-Progress @WriteProgress;
	if($act.AutoRemove -And ($act.MaxItems -eq $act.CurrentItem)) {
		$null = Remove-ActivityProgress -Confirm:$false;
	} # if
	$fReturn = $true;
	$OutputParameter = $fReturn;

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
} # END

} # function
Export-ModuleMember -Function Set-ActivityProgress;

