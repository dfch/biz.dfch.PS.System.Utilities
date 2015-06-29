
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
	
		It "Should-ContainCorrectHeaders" {

			$Script:HeadersMocked = "NOT-INITIALISED";
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

				$Script:HeadersMocked = $Headers.Clone();
			}

			'27999112345' | Send-ShortMessage -Message 'hello, world!' -Credential e2c479178dd741aabe4d05c25db9b9b3;
			
			$Script:HeadersMocked.Authorization -match '^Bearer\ \w+$' | Should Be $true;
			$Script:HeadersMocked.'X-Version' | Should Be '1';
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
