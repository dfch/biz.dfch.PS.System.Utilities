# http://blogs.technet.com/b/jamesone/archive/2010/01/19/how-to-pretty-print-xml-from-powershell-and-output-utf-ansi-and-other-non-unicode-formats.aspx
function Format-Xml {
	[CmdletBinding(
		HelpURI='http://dfch.biz/biz/dfch/PS/System/Utilities/Format-Xml/'
    )]
	[OutputType([string])]
	PARAM (
		[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'file')]
		$File
		,
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0, ParameterSetName = 'string')]
		$String
	)
	BEGIN {
	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	#Log-Debug -fn $fn -msg ("CALL. ExceptionString: '{0}'; idError: '{1}'; ErrorCategory: '{2}'; " -f $ExceptionString, $idError, $ErrorCategory) -fac 1;
	}
	PROCESS {
	$doc = New-Object System.Xml.XmlDataDocument;
	switch ($PsCmdlet.ParameterSetName) {
    "file"  { 
		$fReturn = Test-Path $File -ErrorAction:SilentlyContinue;
		if($fReturn) {
			$doc.Load((Resolve-Path $File));
		} else {
			$doc.LoadXml($File)
		} # if
	}
    "string"  {
		$doc.LoadXml($String)
	}
	} # switch
	$sw = New-Object System.IO.StringWriter;
	$writer = New-Object System.Xml.XmlTextWriter($sw);
	$writer.Formatting = [System.Xml.Formatting]::Indented;
	$doc.WriteContentTo($writer);
	$doc = 
	return $sw.ToString();
	} # PROCESS
	END {
	$datEnd = [datetime]::Now;
	#Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	} # END
} # Format-Xml
Set-Alias -Name fx -Value Format-Xml;
Export-ModuleMember -Function Format-Xml -Alias fx;

