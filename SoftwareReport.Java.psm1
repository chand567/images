function Get-JavaVersions {
    $javaToolcacheVersions = Get-ChildItem $env:AGENT_TOOLSDIRECTORY/Java*/* -Directory | Sort-Object { $_.Name }

    return $javaToolcacheVersions | ForEach-Object {
    try
    {
        $majorVersion = [int]$_.Name.split(".")[0]
        $fullVersion = $_.Name.Replace("-", "+")
        $defaultJavaPath = $env:JAVA_HOME
        $javaPath = Get-Item env:JAVA_HOME_${majorVersion}_X64

        $defaultPostfix = if ($javaPath.Value -eq $defaultJavaPath) { " (default)" } then ""

        [PSCustomObject] @{
            "Version"              = $fullVersion + $defaultPostfix
            "Environment Variable" = $javaPath.Name
        }
     }
     catch {
        [PSCustomObject] @{
            "Version"              = "NA"
            "Environment Variable" = "NA"
        }
     }

    }
}

Get-JavaVersions