﻿# DFTODO - add script skeleton to script file

function Get-Priority {
PARAM 
(

	[ValidateRange(1,[Int32]::MaxValue)]
	[Parameter(Mandatory = $false, Position = 0)]
	[Int32]
	$Id = $PID 
)

	$process = Get-Process -Id $PID;
	return $process.PriorityClass.ToString();

}

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Merge-Hashtable; } 

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

