function Import-Credential{
	[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="Low",
	HelpURI='http://dfch.biz/PS/System/Utilities/Export-Credential/'
    )]
Param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $True, Position = 0)]
	[string] $Path
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $KeyPhrase = [NullString]::Value
	)

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. Path '{0}'. KeyPhrase.Count '{1}'." -f $Path, $KeyPhrase.Count) -fac 1;
# Default test variable for checking function response codes.
[Boolean] $fReturn = $false;
# Return values are always and only returned via OutputParameter.
$OutputParameter = $null;
try {

	# Parameter validation
	# N/A
	if($PSCmdlet.ShouldProcess($Path)) {
		$Credential = Import-CliXml $Path;
		if($KeyPhrase) {
			$KeyPhrase = $KeyPhrase.PadRight(32, '0').Substring(0, 32);
			$Enc = [System.Text.Encoding]::UTF8;
			$k = $Enc.GetBytes($KeyPhrase);
			
			$Credential.Password = $Credential.Password | ConvertTo-SecureString -Key $k;
			$Credential = New-Object System.Management.Automation.PSCredential($Credential.Username, $Credential.Password);
		} else {
			$Credential = Import-CliXml $Path;
		} # if
		$fReturn = $true;
		$OutputParameter = $Credential;
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
			Log-Critical $fn ("[WebException] Request FAILED with Status '{0}'. [{1}]." -f $_.Status, $_);
			Log-Debug $fn $ErrorText -fac 3;
		} # [System.Net.WebException]
		else {
			Log-Error $fn $ErrorText -fac 3;
			if($gotoError -eq $_.Exception.Message) {
				Log-Error $fn $e.Exception.Message;
				$PSCmdlet.ThrowTerminatingError($e);
			} elseif($gotoFailure -eq $_.Exception.Message) { 
				Write-Verbose ("$fn`n$ErrorText"); 
			} else {
				throw($_);
			} # if
		} # other exceptions
		$fReturn = $false;
		$OutputParameter = $null;
	} # !$gotoSuccess
} # catch
finally {
	# Clean up

	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
} # finally
return $OutputParameter;

} # Import-Credential
Export-ModuleMember -Function Import-Credential;

