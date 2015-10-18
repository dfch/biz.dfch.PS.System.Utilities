
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Update-Signature.Tests" "Update-Signature.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"

	Context "Test-CmdletExists" {

		It "GettingHelp-ShouldSucceed" {
			# Act / Assert
			Get-Help Update-Signature | Should Not Be $Null;
		}
    }
}

#
# Copyright 2015 d-fens GmbH
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

