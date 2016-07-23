
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Get-DataType.Tests" "Get-DataType.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"

	Context "Test-CmdletExists" {

		It "GettingHelp-ShouldSucceed" {
			# Act / Assert
			Get-Help Get-DataType | Should Not Be $Null;
		}
    }

	Context "Test-WithSingleDataType" {

		It "GettingValidDataTypeViaRegEx-ReturnsSingleItem" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands.OutHostCommand'

			# Assert
			$result | Should Not Be $null
			$result.Count | Should Be 1;
		}

		It "GettingValidDataTypeViaRegEx-ReturnsSingleItem" {

			# Arrange

			# Act 
			$result = Get-DataType '^Microsoft.PowerShell.Commands.OutHostCommand$'

			# Assert
			$result | Should Not Be $null
			$result.Count | Should Be 1;
		}
		
		It "GettingInvalidDataTypeLiteral-ReturnsNull" {

			# Arrange

			# Act 
			$result = Get-DataType 'Inexistent.Data.Type' -Literal

			# Assert
			$result | Should Be $null
		}
		
		It "GettingValidDataTypeIncludeProperties-ReturnsProerties" -Test {

			# Arrange
			$name = '^System.Uri$';
			
			# Act 
			$result = Get-DataType $name -prop -ctor

			# Assert
			$result | Should Not Be $null
			$result.Count -gt 0 | Should Be $true;
			$result[0].Name | Should Not Be $null;
			$result[0].PropertyType | Should Not Be $null;
		}
	}

	Context "Test-WithSingleDataTypeIncludeInstructor" {

		It "GettingValidDataTypeIncludeInstructor-ReturnsList" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands.OutHostCommand' -ctor

			# Assert
			$result | Should Not Be $null
			$result.Count | Should Be 2;
			$result[0] | Should Not Be $null
			$result[0] | Should Be 'Microsoft.PowerShell.Commands.OutHostCommand';
			$result[1] | Should Not Be $null
			$result[1] -match 'OutHostCommand' | Should Be $true;
		}

	}
	Context "Test-WithMultipleDataTypes" {

		It "GettingValidDataType-ReturnsList" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands'

			# Assert
			$result | Should Not Be $null
			$result.Count -gt 1 | Should Be $true;
		}

		It "GettingValidDataTypeWithRegex-ReturnsList" {

			# Arrange

			# Act 
			$result = Get-DataType '^Microsoft.PowerShell.Commands'

			# Assert
			$result | Should Not Be $null
			$result.Count -gt 1 | Should Be $true;
		}

		It "GettingValidDataTypeCase-ReturnsList" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands' -Case

			# Assert
			$result | Should Not Be $null
			$result.Count -gt 1 | Should Be $true;
		}

		It "GettingValidDataTypeWithRegexCase-ReturnsList" {

			# Arrange

			# Act 
			$result = Get-DataType '^Microsoft.PowerShell.Commands' -Case

			# Assert
			$result | Should Not Be $null
			$result.Count -gt 1 | Should Be $true;
		}

		It "GettingInvalidDataTypeLiteral-ReturnsEmptyList" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands' -Literal

			# Assert
			$result | Should Be $null
		}

		It "GettingInvalidDataTypeWithCaseLiteral-ReturnsEmptyList" {

			# Arrange

			# Act 
			$result = Get-DataType 'Microsoft.PowerShell.Commands' -Literal

			# Assert
			$result | Should Be $null
		}
		
		It "GettingInvalidDataTypeCase-ReturnsEmptyList" {

			# Arrange

			# Act 
			$result = Get-DataType 'microsoft.PowerShell.Commands' -Case

			# Assert
			$result | Should Be $null
		}

		It "GettingInvalidDataTypeWithRegexCase-ReturnsEmptyList" {

			# Arrange

			# Act 
			$result = Get-DataType '^microsoft.PowerShell.Commands' -Case

			# Assert
			$result | Should Be $null
		}
    }
}

#
# Copyright 2016 d-fens GmbH
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
