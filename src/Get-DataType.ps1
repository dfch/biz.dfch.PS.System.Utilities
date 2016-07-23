#requires -Modules biz.dfch.PS.System.Utilities
function Get-DataType {
<#
.SYNOPSIS
Retrieves information about a .NET data type.

.DESCRIPTION
Retrieves information about a .NET data type.

You can search for arbitrary data types that loaded in the current PowerShell 
session via exact name or regex search patterns (default).
In addition you can also display the constructor of all found data types.

.INPUTS
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

In addition output can be filtered on specified properties.

.EXAMPLE
# Searches for all data types that contain 'System.Uri'
PS > Get-DataType System.Uri
System.Uri
System.UriBuilder
System.UriComponents
System.UriFormat
System.UriFormatException
System.UriHostNameType
System.UriIdnScope
System.UriKind
System.UriParser
System.UriPartial
System.UriTemplate
System.UriTemplateEquivalenceComparer
System.UriTemplateMatch
System.UriTemplateMatchException
System.UriTemplateTable
System.UriTypeConverter

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri'
PS > Get-DataType System.Uri -Literal
System.Uri

.EXAMPLE
# Searches for all data types that end with 'System.Uri'
PS > Get-DataType System.Uri$
System.Uri

.EXAMPLE
# Searches for all data types that end with 'System.Uri' (case sensitive)
PS > Get-DataType System.Uri$ -Case
System.Uri

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri' 
# and also display their public constructors
PS > Get-DataType System.Uri -Literal -IncludeConstructor
System.Uri
Uri(
        String uriString,
)
Uri(
        String uriString,
        Boolean dontEscape,
)
Uri(
        Uri baseUri,
        String relativeUri,
        Boolean dontEscape,
)
Uri(
        String uriString,
        UriKind uriKind,
)
Uri(
        Uri baseUri,
        String relativeUri,
)
Uri(
        Uri baseUri,
        Uri relativeUri,
)

.EXAMPLE
# Searches for a data type that is exactly called 'System.Uri' 
# and also display their public constructors
PS > Get-DataType System.Uri -prop -ctor
Name           PropertyType
----           ------------
AbsolutePath   System.String
AbsoluteUri    System.String
LocalPath      System.String
Authority      System.String
HostNameType   System.UriHostNameType
IsDefaultPort  System.Boolean
IsFile         System.Boolean
IsLoopback     System.Boolean
PathAndQuery   System.String
Segments       System.String[]
IsUnc          System.Boolean
Host           System.String
Port           System.Int32
Query          System.String
Fragment       System.String
Scheme         System.String
OriginalString System.String
DnsSafeHost    System.String
IdnHost        System.String
IsAbsoluteUri  System.Boolean
UserEscaped    System.Boolean
UserInfo       System.String
Uri(
        String uriString,
)
Uri(
        String uriString,
        Boolean dontEscape,
)
Uri(
        Uri baseUri,
        String relativeUri,
        Boolean dontEscape,
)
Uri(
        String uriString,
        UriKind uriKind,
)
Uri(
        Uri baseUri,
        String relativeUri,
)
Uri(
        Uri baseUri,
        Uri relativeUri,
)

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/Get-DataType/

.NOTES
See module manifest for required software versions and dependencies.

#>
[CmdletBinding(
	SupportsShouldProcess = $false
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Get-DataType/'
)]
PARAM
(
	# Data Type to search for. Input is treated as regular expression
	# unlesse otherwise specified in '-Literal'
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $InputObject = '.*'
	,
	# perform case sensitive search if specified
	[Parameter(Mandatory = $false)]
	[Alias('case')]
	[switch] $CaseSensitive = $false
	,
	# perform literal search (i.e. not regex) if specified
	[Parameter(Mandatory = $false)]
	[Alias('noregex')]
	[switch] $Literal = $false
	,
	# also show the constructor of the data type
	[Parameter(Mandatory = $false)]
	[Alias('ctor')]
	[switch] $IncludeConstructor = $false
	,
	# returns an instantiated object of the types found
	[Parameter(Mandatory = $false)]
	[Alias('prop')]
	[switch] $IncludeProperties = $false
)
	$dataTypes = New-Object System.Collections.ArrayList;
	$constructors = New-Object System.Collections.ArrayList;
	
	$assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies();
	foreach($assembly in $assemblies)
	{
		foreach($definedType in $assembly.DefinedTypes)
		{
			if(!(($definedType.IsPublic -eq $true -Or $definedType.IsNestedPublic -eq $true) -And $definedType.IsInterface -ne $true))
			{
				continue;
			}
			
			$definedTypeFullName = $definedType.FullName;
			if($Literal)
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cne $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -ine $InputObject)
					{
						continue;
					}
				}
			}
			else
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cnotmatch $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -inotmatch $InputObject)
					{
						continue;
					}
				}
			}
			
			if($IncludeProperties)
			{
				try
				{
					$obj = $definedType.GetProperties() | Select Name, PropertyType;
					$null = $dataTypes.Add($obj);
				}
				catch
				{
					$null = $dataTypes.Add($definedTypeFullName);
				}
			}
			else
			{
				$null = $dataTypes.Add($definedTypeFullName);
			}
			
			if(!$IncludeConstructor)
			{
				continue;
			}
			$null = $constructors.Add((Get-Constructor $definedTypeFullName));
		}
	}
	
	Write-Output ($dataTypes | Sort);
	if($IncludeConstructor -And (0 -lt $constructors.Count))
	{
		Write-Output ($constructors);
	}
}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-DataType; } 

#
# Copyright 2012-2016 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
