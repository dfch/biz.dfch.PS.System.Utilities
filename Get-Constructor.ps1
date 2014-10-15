function Get-Constructor ([type]$type, [Switch]$FullName) {
    foreach ($c in $type.GetConstructors()) {
        $type.Name + "("
        foreach ($p in $c.GetParameters()) {
             if ($fullName) {
                  "`t{0} {1}," -f $p.ParameterType.FullName, $p.Name 
             } else {
                  "`t{0} {1}," -f $p.ParameterType.Name, $p.Name 
             } # if
        } # foreach
        ")"
    } # foreach
} # Get-Constructor
Export-ModuleMember -Function Get-Constructor;

