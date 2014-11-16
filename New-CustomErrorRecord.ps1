Function New-CustomErrorRecord {
<#

.SYNOPSIS

Creates a custom error record.



.DESCRIPTION

Creates a custom error record.



.OUTPUTS

This Cmdlet returns a [System.Management.Automation.ErrorRecord] parameter. On failure it returns $null.

For more information about output parameters see 'help about_Functions_OutputTypeAttribute'.



.INPUTS

See PARAMETER section for a description of input parameters.

For more information about input parameters see 'help about_Functions_Advanced_Parameters'.



.PARAMETER ExceptionString

The name of the semaphore.



.PARAMETER idError

An optional switch parameter with which to create the semaphore in the global namespace.



.PARAMETER ErrorCategory

A number of milliseconds the Cmdlet should try to acquire the resource before giving up. By default this value is -1, which describes an infinite timeout.



.PARAMETER TargetObject

An optional count of times the semaphore should have initialls free (thus initially reserving a number of instances). By default all instances are "free" and thus not reserved.



.EXAMPLE

Creates

New-CustomErrorRecord -Name "biz-dfch-MySemaphore"



.EXAMPLE

Perform a login to a StoreBox server with username and encrypted password.

New-CustomErrorRecord -UriPortal 'https://promo.ds01.swisscom.com' -Username 'PeterLustig' -Credentials [PSCredentials]



.LINK

Online Version: http://dfch.biz/biz/dfch/PS/System/Utilities/New-CustomErrorRecord/



.NOTES

Requires Powershell v3.

Requires module 'biz.dfch.PS.System.Logging'.

#>
	#This function is used to create a PowerShell ErrorRecord
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/New-CustomErrorRecord/'
    )]
	[OutputType([System.Management.Automation.ErrorRecord])]
	PARAM (
		[Parameter(Mandatory = $false, Position = 0)]
		[alias("msg")]
		[alias("m")]
		[String]
		$ExceptionString = 'Unspecified CustomError encountered.'
		,
		[Parameter(Mandatory = $false, Position = 1)]
		[alias("id")]
		[String]
		$idError = 1
		,
		[Parameter(Mandatory = $false, Position = 2)]
		[alias("cat")]
		[alias("c")]
		[System.Management.Automation.ErrorCategory]
		$ErrorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified
		,
		[Parameter(Mandatory = $false, Position = 3)]
		[alias("obj")]
		[alias("o")]
		[PSObject]
		$TargetObject = $PsCmdlet
	)
	BEGIN {
		$datBegin = [datetime]::Now;
		[string] $fn = $MyInvocation.MyCommand.Name;
		Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	}
	PROCESS {
		[boolean] $fReturn = $false;

		try {
			# Parameter validation
			# N/A

			$exception = New-Object System.Management.Automation.RuntimeException($ExceptionString);
			$customError = New-Object System.Management.Automation.ErrorRecord($exception, $idError, $ErrorCategory, $TargetObject);
			$OutputParameter = $customError;
			
		} # try
		catch {
			if($gotoSuccess -eq $_.Exception.Message) {
				$fReturn = $true;
			} elseif($gotoNotFound -eq $_.Exception.Message) {
				$fReturn = $false;
				$OutputParameter = $null;
			} else {
				[string] $ErrorText = "catch [$($_.FullyQualifiedErrorId)]";
				$ErrorText += (($_ | fl * -Force) | Out-String);
				$ErrorText += (($_.Exception | fl * -Force) | Out-String);
				$ErrorText += (Get-PSCallStack | Out-String);
				
				if($_.Exception.InnerException -is [System.Net.WebException]) {
					Log-Critical $fn "Operation '$Method' '$Api' with UriServer '$UriServer' FAILED [$_].";
					Log-Debug $fn $ErrorText -fac 3;
				} # [System.Net.WebException]
				else {
					Log-Error $fn $ErrorText -fac 3;
					if($gotoFailure -ne $_.Exception.Message) { Write-Verbose ("$fn`n$ErrorText"); }
				} # other exceptions
				$fReturn = $false;
				$OutputParameter = $null;
			} # !$gotoSuccess
		} # catch
		finally {
			# Clean up
		} # finally
		return $OutputParameter;
	} # PROCESS
	END {
		$datEnd = [datetime]::Now;
		Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	} # END
} # New-CustomErrorRecord
# Set-Alias -Name ex -Value New-CustomErrorRecord;
# Set-Alias -Name New-Exception -Value New-CustomErrorRecord;
# Export-ModuleMember -Function New-CustomErrorRecord -Alias New-Exception, ex;
Export-ModuleMember -Function New-CustomErrorRecord;
