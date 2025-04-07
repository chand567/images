Describe "Android" {
    function Get-AndroidPackages {
        param (
            [Parameter(Mandatory = $false)]
            [string] $SDKRootPath
        )

        if (-not $SDKRootPath) {
            $SDKRootPath = $env:ANDROID_HOME
        }

        $packagesListFile = "$SDKRootPath/packages-list.txt"

        if (-not (Test-Path -Path $packagesListFile -PathType Leaf)) {
            # Retry mechanism for sdkmanager command
            $maxRetries = 3
            $retryIntervalSeconds = 5
            $attempt = 0
            $success = $false

            while (-not $success -and $attempt -lt $maxRetries) {
                try {
                    "/usr/local/lib/android/sdk/cmdline-tools/latest/bin/sdkmanager --list --verbose" 2>&1 |
                        Where-Object { $_ -Match "^[^\s]" } |
                        Where-Object { $_ -NotMatch "^(Loading |Info: Parsing |---|\[=+|Installed |Available )" } |
                        Where-Object { $_ -NotMatch "^[^;]*$" } |
                        Out-File -FilePath $packagesListFile
                    $success = $true
                } catch {
                    Write-Warning "Attempt $($attempt + 1) failed. Retrying in $retryIntervalSeconds seconds..."
                    Start-Sleep -Seconds $retryIntervalSeconds
                    $attempt++
                }
            }

            if (-not $success) {
                throw "Failed to generate the Android packages list after $maxRetries attempts."
            }

            Write-Host "Android packages list:"
            Get-Content $packagesListFile
        }

        return Get-Content $packagesListFile
    }

    $androidSdkManagerPackages = Get-AndroidPackages
    [int]$platformMinVersion = (Get-ToolsetContent).android.platform_min_version
    [version]$buildToolsMinVersion = (Get-ToolsetContent).android.build_tools_min_version
    [array]$ndkVersions = (Get-ToolsetContent).android.ndk.versions
    $ndkFullVersions = $ndkVersions |
        ForEach-Object { (Get-ChildItem "/usr/local/lib/android/sdk/ndk/${_}.*" |
        Select-Object -Last 1).Name } | ForEach-Object { "ndk/${_}" }

    $platformVersionsList = ($androidSdkManagerPackages |
        Where-Object { "$_".StartsWith("platforms;") }) -replace 'platforms;android-', '' |
        Where-Object { $_ -match "^\d" } | Sort-Object -Unique

    $platformsInstalled = $platformVersionsList |
        Where-Object { [int]($_.Split("-")[0]) -ge $platformMinVersion } |
        ForEach-Object { "platforms/android-${_}" }

    $buildToolsList = ($androidSdkManagerPackages | Where-Object { "$_".StartsWith("build-tools;") }) -replace 'build-tools;', ''
    $buildTools = $buildToolsList |
        Where-Object { $_ -match "\d+(\.\d+){2,}$"} |
        Where-Object { [version]$_ -ge $buildToolsMinVersion } |
        Sort-Object -Unique |
        ForEach-Object { "build-tools/${_}" }

    $androidPackages = @(
        $platformsInstalled,
        $buildTools,
        $ndkFullVersions,
        ((Get-ToolsetContent).android.extra_list | ForEach-Object { "extras/${_}" }),
        ((Get-ToolsetContent).android.addon_list | ForEach-Object { "add-ons/${_}" }),
        ((Get-ToolsetContent).android.additional_tools | ForEach-Object { "${_}" })
    )

    $androidPackages = $androidPackages | ForEach-Object { $_ }

    Context "SDKManagers" {
        $testCases = @(
            @{
                PackageName = "Command-line tools"
                Sdkmanager = "$env:ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
            }
        )

        It "Sdkmanager from <PackageName> is available" -TestCases $testCases {
            param ($Sdkmanager)

            if (-not (Test-Path $Sdkmanager)) {
                throw "Sdkmanager binary not found at path: $Sdkmanager"
            }

            # Retry mechanism for Sdkmanager version check
            $maxRetries = 3
            $retryIntervalSeconds = 5
            $attempt = 0
            $success = $false

            while (-not $success -and $attempt -lt $maxRetries) {
                try {
                    "$Sdkmanager --version" | Should -ReturnZeroExitCode
                    $success = $true
                } catch {
                    Write-Warning "Attempt $($attempt + 1) failed. Retrying in $retryIntervalSeconds seconds..."
                    Start-Sleep -Seconds $retryIntervalSeconds
                    $attempt++
                }
            }

            if (-not $success) {
                throw "Failed to validate Sdkmanager after $maxRetries attempts."
            }
        }
    }

    Context "Packages" {
        $testCases = $androidPackages | ForEach-Object { @{ PackageName = $_ } }

        It "<PackageName>" -TestCases $testCases {
            $PackageName = $PackageName.Replace(";", "/")
            $targetPath = Join-Path $env:ANDROID_HOME $PackageName
            $targetPath | Should -Exist
        }
    }
}
