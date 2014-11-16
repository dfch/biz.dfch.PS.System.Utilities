function Get-ComObjectType {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/Get-ComObjectType/'
    )]
	PARAM(
	    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory = $true, Position=0)]
		[ref] 
		$InputObject
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. InputObject: '{0}'" -f $InputObject) -fac 1;
	} # BEGIN
	PROCESS {
	$fReturn = $false;
	$OutputParameter = $null;

	$TypeName = $null;
	#$InputObject | gm;
	$v = $InputObject.Value;
	#$v.GetType();
	$fReturn = $false;
	foreach($PSTypeName in $v.pstypenames) {
		#$PSTypeName
		#$PSTypeName.GetType();
		$Matches = $null;
		$fReturn = $PSTypeName -match '^System.__ComObject#({.+})$';
		if($fReturn) { break; }
	} #foreach
	if(!$fReturn) {
		Log-Error $fn ("InputObject is not a ComObject: '{0}'" -f $InputObject.GetType());
		$OutputParameter = $null;
	} else {
		$Type = $Matches[1];
		$TypeName = (Get-ItemProperty "HKLM:\SOFTWARE\Classes\Interface\$type").'(default)';
		Log-Debug $fn ("InputObject resolved to type: '{0}'" -f $TypeName);
		$OutputParameter = $TypeName;
	} # if
	return $OutputParameter;
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	} # END
} # Get-ComObjectType
Export-ModuleMember -Function Get-ComObjectType;

