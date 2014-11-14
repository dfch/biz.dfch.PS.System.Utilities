Function ConvertFrom-CmdletHelp {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/ConvertFrom-CmdletHelp/'
    )]
	PARAM (
	$CommandName = $MyInvocation.MyCommand.Name
	,
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty', 'markdown', 'gridview')]
	[Parameter(Mandatory = $false)]
	[alias("ReturnFormat")]
	[string] $As = 'default'
	)

	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	# Return values are always and only returned via OutputParameter.
	$OutputParameter = $null;
	
	[string] $fn = $MyInvocation.MyCommand.Name;

	$helpFormatted = @();
	foreach($line in ((help $CommandName -Full))) { 
	  if( ![string]::IsNullOrWhiteSpace($line) -and $line -ceq $line.ToUpper() ) {
		$line = "{0}`r`n" -f $line; 
	  } # if
	  if($line -match '\-+\ (\w+)\ (\d+)\ \-+') {
		$line = "{0}{1}`r`n" -f $Matches[1], $Matches[2]; 
	  } # if
	  $helpFormatted += $line; 
	} # foreach

	$r = $helpFormatted;
	switch($As) {
	'xml' { $OutputParameter = (ConvertTo-Xml -InputObject $r).OuterXml; }
	'xml-pretty' { $OutputParameter = Format-Xml -String (ConvertTo-Xml -InputObject $r).OuterXml; }
	'json' { $OutputParameter = ConvertTo-Json -InputObject $r -Compress; }
	'json-pretty' { $OutputParameter = ConvertTo-Json -InputObject $r; }
	'gridview' { $r | Out-GridView -Title $CommandName; }
	Default { $OutputParameter = $r; }
	} # switch
	$fReturn = $true;
	return $OutputParameter
} # ConvertFrom-CmdletHelp
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function ConvertFrom-CmdletHelp; }

<#
2014-11-12; rrink; ADD: handling of EXAMPLE sections
2014-11-10; rrink; ADD: ConvertFrom-CmdletHelp
#>
