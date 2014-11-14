function Test-StringPattern {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PSSystem/Utilities/Get-ComObjectType/'
    )]
PARAM (
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)]
	$InputObject
	,
	[Parameter(Mandatory=$false,ParameterSetName='guid')]
	[switch] $Guid
	,
	[Parameter(Mandatory=$false,ParameterSetName='urn')]
	[switch] $Urn
	,
	[ValidateSet('guid', 'urn', 'hp', 'hp4345', 'hp3027', 'lx544', 'scan')]
	[Parameter(Mandatory=$false,ParameterSetName='type')]
	[string] $Type
	,
	[Parameter(Mandatory=$false)]
	[switch] $Extract = $false
)

[string] $fn = $MyInvocation.MyCommand.Name;
#Write-Host $PSCmdlet.ParameterSetName
$fReturn = $false;
$OutputParameter = $null;
$Matches = $null;

#$InputObject = 'urn:vcloud:vcd:559ccf96-1cc5-4f79-ba4e-69dd1fa66fab';
switch($PSCmdlet.ParameterSetName) {
'guid' {
	$Pattern = '[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}';
	$fReturn = $InputObject -match $Pattern;
}
'urn' {
	$Pattern = '(urn:vcloud:[^:]+):([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})';
	$fReturn = $InputObject -match $Pattern;
}
'type' {
	switch($Type) {
	'hp' {
		$Pattern = '^(?<Name>doc-?[^_]*)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		#if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'hp4345' {
		$Pattern = '^(?<Name>doc-?[^_]*)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		#if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'hp3027' {
		$Pattern = '^(?<Name>\[[^\-_]+-?)_(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'lx544' {
		$Pattern = '^(?<Name>doc)-(?<Year>\d{4})(?<Month>\d{2})(?<Day>\d{2})_(?<Hour>\d{2})(?<Minute>\d{2})(?<Second>\d{2})(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	'scan' {
		$Pattern = '^(?<Name>doc)---(?<Year>\d{4})-(?<Month>\d{2})-(?<Day>\d{2})---(?<Hour>\d{2})-(?<Minute>\d{2})-(?<Second>\d{2})---(?<Counter>\d{2})(?<Extension>\..+)$';
		$fReturn = $InputObject -match $Pattern;
		if($fReturn -and ( ($Matches.Year -le 1300) -or ($Matches.Month -gt 12) -or ($Matches.Day -gt 31) )) { $fReturn = $false; }
	}
	default {
		$e = New-CustomErrorRecord -m ("Cannot validate argument on parameter 'Type': '{0}'. Aborting ..." -f $Type) -cat InvalidData -o $Type;
		Log-Error $fn $e.Exception.Message;
		$PSCmdlet.ThrowTerminatingError($e);
	}
	} # switch
}
default {
	$e = New-CustomErrorRecord -m ("A parameter cannot be found that matches parameter name 'PSCmdlet.ParameterSetName': '{0}'. Aborting ..." -f $PSCmdlet.ParameterSetName) -cat InvalidArgument -o $PSCmdlet.ParameterSetName;
	Log-Error $fn $e.Exception.Message;
	$PSCmdlet.ThrowTerminatingError($e);
}
} # switch

if($Extract -and $fReturn) { 
	$OutputParameter = $Matches; 
} else {
	$OutputParameter = $fReturn; 
} #  if
return $OutputParameter;

} # Test-StringPattern
Export-ModuleMember -Function Test-StringPattern;

