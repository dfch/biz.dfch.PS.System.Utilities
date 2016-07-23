
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Merge-Hashtable.Tests" "Merge-Hashtable.Tests" {

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

	Context "Test-Intersect" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';

		$htRight = @{};
		$htRight.key1 = 'value1-right';
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';

		$resultCount = 1;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersect;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersect;
			$result.Count | Should Be $resultCount;
		}

		It 'ShouldBe-Intersect1' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersect;
			$result.ContainsKey('key1') | Should Be $true;
			$result.key1 | Should Be $htLeft.key1;
		}

		It 'ShouldBe-Intersect12' {
			$result = Merge-Hashtable -Left $htRight -Right $htLeft -Action Intersect;
			$result.ContainsKey('key1') | Should Be $true;
			$result.key1 | Should Be $htRight.key1;
		}
	}

	Context "Test-EmptyIntersect" {
		$htLeft = @{};
		$htLeft.key2 = 'value2-left';

		$htRight = @{};
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';

		$resultCount = 0;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersect;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Intersect;
			$result.Count | Should Be $resultCount;
		}
	}

	Context "Test-Outersect" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';
		$htLeft.key5 = 'value5-left';

		$htRight = @{};
		$htRight.key1 = 'value1-right';
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';
		$htRight.key6 = 'value6-right';

		$resultCount = 5;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Outersect;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Outersect;
			$result.Count | Should Be $resultCount;
		}

		It 'ShouldBe-Outersect1' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Outersect;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.ContainsKey('key5') | Should Be $true;
			$result.ContainsKey('key6') | Should Be $true;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result.key5 | Should Be $htLeft.key5;
			$result.key6 | Should Be $htRight.key6;
		}

		It 'ShouldBe-Outersect2' {
			$result = Merge-Hashtable -Left $htRight -Right $htLeft -Action Outersect;
			$result.ContainsKey('key2') | Should Be $true;
			$result.ContainsKey('key3') | Should Be $true;
			$result.ContainsKey('key4') | Should Be $true;
			$result.ContainsKey('key5') | Should Be $true;
			$result.ContainsKey('key6') | Should Be $true;
			$result.key2 | Should Be $htLeft.key2;
			$result.key3 | Should Be $htRight.key3;
			$result.key4 | Should Be $htRight.key4;
			$result.key5 | Should Be $htLeft.key5;
			$result.key6 | Should Be $htRight.key6;
		}
	}

	Context "Test-EmptyOutersect" {
		$htLeft = @{};
		$htLeft.key1 = 'value1-left';
		$htLeft.key2 = 'value2-left';
		$htLeft.key3 = 'value3-left';
		$htLeft.key4 = 'value4-left';

		$htRight = @{};
		$htRight.key1 = 'value1-right';
		$htRight.key2 = 'value2-right';
		$htRight.key3 = 'value3-right';
		$htRight.key4 = 'value4-right';

		$resultCount = 0;

		It 'ShouldBe-TypeHashtable' {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Outersect;
			$result -is [hashtable] | Should Be $true;
		}

		It "ShouldBe-CountHashtable$resultCount" {
			$result = Merge-Hashtable -Left $htLeft -Right $htRight -Action Outersect;
			$result.Count | Should Be $resultCount;
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUQX392R521DJaQRAUlPSahmRw
# YN2gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIdaZp2SXPvH4Qn7pGcxTQRQwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTYwNTI0MDAwMDAwWhcNMjcwNjI0MDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAj6kakW0EpjcgDoOW3iPTa24f
# bt1kPWghIrX4RzZpjuGlRcckoiK3KQnMVFquxrzNY46zPVBI5bTMrs2SjZ4oixNK
# Eaq9o+/Tsjb8tKFyv22XY3mMRLxwL37zvN2CU6sa9uv6HJe8tjecpBwwvKu8LUc2
# 35IgA+hxxlj2dQWaNPALWVqCRDSqgOQvhPZHXZbJtsrKnbemuuRQ09Q3uLogDtDT
# kipbxFm7oW3bPM5EncE4Kq3jjb3NCXcaEL5nCgI2ZIi5sxsm7ueeYMRGqLxhM2zP
# TrmcuWrwnzf+tT1PmtNN/94gjk6Xpv2fCbxNyhh2ybBNhVDygNIdBvVYBAexGDCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQUVd+iUfoDdoGD
# FHgoZSH2Y6CQfzANBgkqhkiG9w0BAQEFAASCAQA/mmnZcQ0fkdOeqU5Crwe1VTAL
# rg1VTQdZPW13oTzCMrc1E8UqO4ZmYovp1RGe8epgj2VUTChYNHsPH9RERc0yugsr
# Fsk2vcftjp1vtVfEPZyGXCcUnqFBLIYYv4hP5ngHF0DBh/zY5FamcYiSomfwcGp0
# F7Uf0kNd9/BBSyWVYPdb3TWe4JQt6fQf9ooAueXSrt+8mo9fKCqP5tu4YbZTSI4u
# tidu8KJ8DkoVluiAmQd7+kJXhRsmADwv+xFNPrkfY9Q/q/2n7st2N9sqMrWFlsQm
# SexIKDAc4XrG4R39GQr7pk0Li+jfE3iJtUmMzl2OH0u5Hym5NdvVRXRatFqPoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEh1pmnZJc+8fhCfukZzFNBFDAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE2
# MDcyMzE3Mzk0MlowIwYJKoZIhvcNAQkEMRYEFJBBo974YJjr8I9YU5r/A7jnYNM4
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUY7gvq2H1g5CWlQULACScUCkz
# 7HkwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# 1pmnZJc+8fhCfukZzFNBFDANBgkqhkiG9w0BAQEFAASCAQB85XPAPAIdK21ScV+B
# qeQmhMNszMU+zeDkDFCdy6WKWkboAIZeprt0zfYRlw89bgrjQ0FvKMIY31CtJEei
# Hf1FveFvgIkIyFR1gG13xCN82rlwk6a4UICc9a/Bwl5c/Pf2IbXWhTa0mdZ8GWU0
# IIz9COkcbjROxlfh4ZumQlrWiaH4tVgD7iIL+cmle3aUJkXqLJDVqWzJn1WhWrF2
# p6ICeDkK/sVmPizCSOuN5mSafnaZQUgRVRnx+Gsi2eDLMlk3e+qxFKT/fu03tLwT
# v0eGseRvv0gjJA6EERUnxhH1q+IEIkohtctPQCIkK+YeOQKNrVjgCLCObfxDi5cK
# kbuO
# SIG # End signature block
