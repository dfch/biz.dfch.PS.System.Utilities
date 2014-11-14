function Set-SslSecurityPolicy {
	[CmdletBinding(
    SupportsShouldProcess=$true,
    ConfirmImpact="High",
	HelpURI='http://dfch.biz/biz/dfch/PSSystem/Utilities/Set-SslSecurityPolicy/'
    )]
Param(
	[Parameter(Mandatory = $false, Position = 0)]
	[switch] $TrustAllCertificates = $true
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[switch] $CheckCertificateRevocationList = $false
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[switch] $ServerCertificateValidationCallback = $true
	)

	if($PSCmdlet.ShouldProcess("")) {
	
		if($TrustAllCertificates) {
Add-Type @"
	using System.Net;
	using System.Security.Cryptography.X509Certificates;
	public class TrustAllCertsPolicy : ICertificatePolicy {
	   public bool CheckValidationResult(
			ServicePoint srvPoint, X509Certificate certificate,
			WebRequest request, int certificateProblem) {
			return true;
		}
	}
"@
			[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;
		} # if
		if(!$CheckCertificateRevocationList) {
			[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false;
		} # if
		if($ServerCertificateValidationCallback) {
			[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true; };
		} #if
	} # if

} # Set-SslSecurityPolicy
Export-ModuleMember -Function Set-SslSecurityPolicy;

