
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Test-Merge-Hashtable" "Test-Merge-Hashtable" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"

	$htLeftNull = $null;
	$htLeftEmpty = @{};

	$htRightNull = $null;
	$htRightEmpty = @{};

	Context "Test-InvalidInput" {
	
		It "ShouldThrow-OnNullInput" {
			{ Merge-Hashtable -Left $htLeftNull -Right $htRightNull } | Should Throw
		}

		It "ShouldThrow-OnLeftNullInput" {
			{ Merge-Hashtable -Left $htLeftNull -Right $htRightEmpty } | Should Throw
		}

		It "ShouldThrow-OnRightNullInput" {
			{ Merge-Hashtable -Left $htLeftEmpty -Right $htRightNull } | Should Throw
		}

	}

	Context "Test-EmptyResult" {
		$htLeft = @{};
		$htRight = @{};

		$resultCount = 0;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepLeft;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepRight;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-EmptyHashtable" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepLeft;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepRight;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
		}
	}

	Context "Test-MergeDistinct" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';

		$htRight = @{};
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';
		
		$resultCount = 4;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepLeft;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepRight;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result -is [hashtable] | Should Be $true;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepLeft;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepRight;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
		}

		It 'ShouldBe-MergedHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepLeft;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action KeepRight;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
		}
	}
	
	Context "Test-OverwriteLeft" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';

		$htRight = @{};
		$htRight.key1 = 'value1-right';
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';

		$resultCount = 4;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result.Count | Should Be $resultCount;
		}

		It 'ShouldBe-RightKeyExists' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteLeft;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htRight.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
		}
	}
	
	Context "Test-OverwriteRight" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';

		$htRight = @{};
		$htRight.key1 = 'value1-right';
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';

		$resultCount = 4;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result.Count | Should Be $resultCount;
		}

		It 'ShouldBe-LeftKeyExists' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action OverwriteRight;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
		}
	}
	
	Context "Test-FailOnDuplicateKeys" {

		It "ShouldBe-NullOnDuplicateKeys" {
			$htLeft = @{};
			$htLeft.key1 = 'value1-left';
			$htLeft.key3 = 'value3-left';

			$htRight = @{};
			$htRight.key1 = 'value1-right';
			$htRight.key2 = 'value2-right';

			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result | Should Be $null;
		}
	
		It "ShouldBe-MergedHashtableOnDistinctKeys" {
			$htLeft = @{};
			$htLeft.key1 = 'value1-left';
			$htLeft.key3 = 'value3-left';
			$htLeft.key4 = 'value4-left';

			$htRight = @{};
			$htRight.key2 = 'value2-right';
			
			$resultCount = 4;

			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action FailOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htRight.key2;
			$result.key3 | Should Be $htLeft.key3;
			$result.key4 | Should Be $htLeft.key4;
		}
	}
	
	Context "Test-ThrowOnDuplicateKeys" {

		It "ShouldThrow-OnDuplicateKeys" {
			$htLeft = @{};
			$htLeft.key1 = 'value1-left';
			$htLeft.key3 = 'value3-left';

			$htRight = @{};
			$htRight.key1 = 'value1-right';
			$htRight.key2 = 'value2-right';

			{ Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys } | Should Throw;
		}
	
		It "ShouldBe-MergedHashtableOnDistinctKeys" {
			$htLeft = @{};
			$htLeft.key1 = 'value1-left';
			$htLeft.key3 = 'value3-left';
			$htLeft.key4 = 'value4-left';

			$htRight = @{};
			$htRight.key2 = 'value2-right';
			
			$resultCount = 4;

			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action ThrowOnDuplicateKeys;
			$result.Count | Should Be $resultCount;
			$result.ContainsKey('key1') | Should Be $true;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
			$result.key2 | Should Be $htRight.key2;
			$result.key3 | Should Be $htLeft.key3;
			$result.key4 | Should Be $htLeft.key4;
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
