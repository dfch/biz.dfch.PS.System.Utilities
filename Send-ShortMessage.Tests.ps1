
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Test-Send-ShortMessage" "Test-Send-ShortMessage" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"

	$htLeftNull = $null;
	$htLeftEmpty = @{};

	$htRightNull = $null;
	$htRightEmpty = @{};

	Context "Test-Send-ShortMessage" {
	
		It "ShouldBe-CorrectRestRequest" {

			$Script:PSBoundParametersMocked = "NOT-INITIALISED";
			function Invoke-RestMethod(
				[String] $Method
				,
				[Uri] $Uri
				,
				[String] $ContentType
				,
				[Hashtable] $Headers
				,
				[Object] $Body
				)
			{

				$Script:PSBoundParametersMocked = $PSBoundParameters;
				throw;
			}

			$BearerToken = 'e2c479178dd741aabe4d05c25db9b9b3';
			$PhoneNumber = '27999112345';
			$Message = 'hello, world!';

			$Method = 'POST';
			$XVersionValue = '1';
			$ContentType = 'application/json';
			[Uri] $Uri = 'https://api.clickatell.com/rest/message';

			$PhoneNumber | Send-ShortMessage -Message $Message -Credential $BearerToken;
			
			$Script:PSBoundParametersMocked.Headers.Authorization -match ('^Bearer\ {0}$' -f $BearerToken) | Should Be $true;
			$Script:PSBoundParametersMocked.Headers.'X-Version' | Should Be $XVersionValue;
			
			$Body = ($Script:PSBoundParametersMocked.Body | ConvertFrom-Json);
			$Body.text -is [String] | Should Be $true;
			$Body.text | Should Be $true;
			$Body.to -is [array] | Should Be $true;
			$Body.to.Count | Should Be 1;
			$Body.to[0] | Should Be $PhoneNumber;
			
			$Script:PSBoundParametersMocked.Method | Should Be $Method;
			
			$Script:PSBoundParametersMocked.Uri -is [Uri] | Should Be $true;
			$Script:PSBoundParametersMocked.Uri.AbsoluteUri | Should Be $Uri.AbsoluteUri;
			
			$Script:PSBoundParametersMocked.ContentType | Should Be $ContentType;
		}

	}
}

##
 #
 #
 # Copyright 2015 Ronald Rink, d-fens GmbH
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
 #
