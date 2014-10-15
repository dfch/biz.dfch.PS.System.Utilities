$fn = $MyInvocation.MyCommand.Name;

Set-Variable gotoSuccess -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoSuccess';
Set-Variable gotoError -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoError';
Set-Variable gotoFailure -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoFailure';
Set-Variable gotoNotFound -Option 'Constant' -Value 'biz.dfch.System.Exception.gotoNotFound';

[string] $ModuleConfigFile = '{0}.xml' -f (Get-Item $PSCommandPath).BaseName;
[string] $ModuleConfigurationPathAndFile = Join-Path -Path $PSScriptRoot -ChildPath $ModuleConfigFile;
$mvar = $ModuleConfigFile.Replace('.xml', '').Replace('.', '_');
if($true -eq (Test-Path -Path $ModuleConfigurationPathAndFile)) {
	if($true -ne (Test-Path variable:$($mvar))) {
		Log-Debug $fn ("Loading module configuration file from: '{0}' ..." -f $ModuleConfigurationPathAndFile);
		Set-Variable -Name $mvar -Value (Import-Clixml -Path $ModuleConfigurationPathAndFile);
	} # if()
} # if()
if($true -ne (Test-Path variable:$($mvar))) {
	Write-Error "Could not find module configuration file '$ModuleConfigFile' in 'ENV:PSModulePath'.`nAborting module import...";
	break; # Aborts loading module.
} # if()
Export-ModuleMember -Variable $mvar;

<#
 # ########################################
 # Version history
 # ########################################
 #
 # 2014-10-15; rrink; CHG: split module in separate PS1 files and use manifest file
 # 2013-12-28; rrink; ADD: Remove-ActivityProgress
 # 2013-12-28; rrink; ADD: Set-ActivityProgress
 # 2013-12-28; rrink; ADD: New-ActivityProgress
 # 2013-11-25; rrink; CHG: $Input to $InputString
 # 2013-10-27; rrink; ADD: Set-SslSecurityPolicy
 # 2013-10-27; rrink; ADD: Get-Constructor
 # 2013-10-24; rrink; ADD: Export-Credential, rewrite to accept pipeline input
 # 2013-10-24; rrink; ADD: Import-Credential, rewrite to accept pipeline input
 # 2013-01-11; rrink; ADD: initial release
 #
 # ########################################
 #>
