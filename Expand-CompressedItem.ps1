function Expand-CompressedItem 
{

[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Low"
	,
	HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/Expand-CompressedItem/'
)]

PARAM
(
	[ValidateScript( { Test-Path($_); } )]
	[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
	[System.IO.FileInfo] $InputObject
	,
	[ValidateScript( { Test-Path($_); } )]
	[Parameter(Mandatory = $true, Position = 1)]
	[System.IO.DirectoryInfo] $Path
	,
	[ValidateSet('default', 'ZIP')]
	[Parameter(Mandatory = $false)]
	[string] $Format = 'default'
)

BEGIN 
{
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. InputObject: '{0}'. Path '{1}'" -f $InputObject.FullName, $Path.FullName) -fac 1;

	# Currently only ZIP is supported
	switch($Format)
	{
		"ZIP"
		{
			# We use the Shell to extract the ZIP file. If using .NET v4.5 we could have used .NET classes directly more easily.
			$ShellApplication = new-object -com Shell.Application;
		}
		default
		{
			# We use the Shell to extract the ZIP file. If using .NET v4.5 we could have used .NET classes directly more easily.
			$ShellApplication = new-object -com Shell.Application;
		}
	}
	$CopyHereOptions = 4 + 1024 + 16;
}

PROCESS 
{
	$fReturn = $false;
	$OutputParameter = $null;

	foreach($Object in $InputObject) 
	{
		if($PSCmdlet.ShouldProcess( ("Extracting '{0}' to '{1}' ..." -f $Object.Name, $Path.FullName) ))
		{
			Log-Debug $fn ("Extracting '{0}' to '{1}' ..." -f $Object.Name, $Path.FullName)
			$CompressedObject = $ShellApplication.NameSpace($Object.FullName);
			foreach($Item in $CompressedObject.Items())
			{
				$ShellApplication.Namespace($Path.FullName).CopyHere($Item, $CopyHereOptions);
			}
		}
	}
	return $OutputParameter;
}

END 
{
	# Cleanup
	if($ShellApplication)
	{
		$ShellApplication = $null;
	}
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
}

} # function
# You might want to add an Alias "unzip" as well
# Set-Alias -Name 'Unzip' -Value 'Expand-CompressedItem';
# if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Expand-CompressedItem -Alias Unzip; } 
if($MyInvocation.PSScriptRoot) { Export-ModuleMember -Function Expand-CompressedItem; } 

<#
2014-11-15; rrink; ADD: Expand-CompressedItem; Initial version
#>