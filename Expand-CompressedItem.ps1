function Expand-CompressedItem {
<# 

.SYNOPSIS

Expands a compressed archive or container.


.DESCRIPTION

Expands a compressed archive or container.

Currently only ZIP files are supported. Per default the contents of the ZIP 
is expanded in the current directory. If an item already exists, you will 
be visually prompted to overwrite it, skip it, or to have a second copy of 
the item exanded. This is due to the mechanism how this is implemented (via 
Shell.Application).


.INPUTS 

InputObject can either be a full path to an archive or a FileInfo object. In 
addition it can also be an array of these objects.

Path expects a directory or a DirectoryInfo object.


.OUTPUTS

This Cmdlet has no return value.


.PARAMETER InputObject
Specifies the archive to expand. You can either pass this parameter as a 
path and name to the archive or as a FileInfo object. You can also pass an 
array of archives to the parameter. In addition you can pipe a single archive 
or an array of archives to this parameter as well.


.PARAMETER Path

Specifies the destination path where to expand the archive. By default this 
is the current directory.


.EXAMPLE

Expands an archive 'mydata.zip' to the current directory.

Expand-CompressedItem mydata.zip


.EXAMPLE

Expands an archive 'mydata.zip' to the current directory and prompts for 
every item to be extracted.

Expand-CompressedItem mydata.zip -Confirm

.EXAMPLE

Get-ChildItem Y:\Source\*.zip | Expand-CompressedItem -Path Z:\Destination -Format ZIP -Confirm

You can also pipe archives to the Cmdlet.
Enumerate all ZIP files in 'Y:\Source' and pass them to the Cmdlet. Each item 
to be extracted must be confirmed.

.EXAMPLE

Expands archives 'data1.zip' and 'data2.zip' to the current directory.

Expand-CompressedItem "Y:\Source\data1.zip","Y:\Source\data2.zip"


.EXAMPLE

Expands archives 'data1.zip' and 'data2.zip' to the current directory.

@("Y:\Source\data1.zip","Y:\Source\data2.zip") | Expand-CompressedItem


.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Expand-CompressedItem/


.NOTES

See module manifest for required software versions and dependencies at: 
http://dfch.biz/biz/dfch/PS/System/Utilities/biz.dfch.PS.System.Utilities.psd1/


.HELPURI


#>
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
	$InputObject
	,
	[ValidateScript( { Test-Path($_); } )]
	[Parameter(Mandatory = $false, Position = 1)]
	[System.IO.DirectoryInfo] $Path = $PWD.Path
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
		$Object = Get-Item $Object;
		if($PSCmdlet.ShouldProcess( ("Extract '{0}' to '{1}'" -f $Object.Name, $Path.FullName) ))
		{
			Log-Debug $fn ("Extracting '{0}' to '{1}' ..." -f $Object.Name, $Path.FullName)
			$CompressedObject = $ShellApplication.NameSpace($Object.FullName);
			foreach($Item in $CompressedObject.Items())
			{
				if($PSCmdlet.ShouldProcess( ("Extract '{0}' to '{1}'" -f $Item.Name, $Path.FullName) ))
				{
					$ShellApplication.Namespace($Path.FullName).CopyHere($Item, $CopyHereOptions);
				}
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
# if($MyInvocation.ScriptName) { Export-ModuleMember -Function Expand-CompressedItem -Alias Unzip; } 
if($MyInvocation.ScriptName) { Export-ModuleMember -Function Expand-CompressedItem; } 

<#
2014-11-15; rrink; ADD: Expand-CompressedItem; Initial version
#>