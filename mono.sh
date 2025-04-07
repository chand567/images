#!/bin/bash
set -e

################################################################################
##  File:  cmake.sh
##  Desc:  Installs Mono
################################################################################

source $HELPER_SCRIPTS/os.sh

LSB_CODENAME=$(lsb_release -cs)

# There are no packages for Ubuntu 22 in the repo, but developers confirmed that packages from Ubuntu 20 should work
if isUbuntu22; then
    LSB_CODENAME="focal"
fi

# Function to retry commands
retry_command() {
    local -r cmd="$1"
    local -r max_attempts=3
    local -r sleep_time=10
    local attempt=1

    until $cmd
    do
        if (( attempt == max_attempts ))
        then
            echo "Command failed after $max_attempts attempts: $cmd"
            return 1
        fi
        echo "Command failed. Retrying in $sleep_time seconds..."
        sleep $sleep_time
        ((attempt++))
    done
}

# Add Mono repository key
retry_command "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF"

# Add Mono repository
echo "deb https://download.mono-project.com/repo/ubuntu stable-$LSB_CODENAME main" | tee /etc/apt/sources.list.d/mono-official-stable.list

# Update package lists
retry_command "apt-get update"

# Install Mono and NuGet
retry_command "apt-get install -y --no-install-recommends apt-transport-https mono-complete nuget"

# Clean up
rm /etc/apt/sources.list.d/mono-official-stable.list
rm -f /etc/apt/sources.list.d/mono-official-stable.list.save
echo "mono https://download.mono-project.com/repo/ubuntu stable-$LSB_CODENAME main" >> $HELPER_SCRIPTS/apt-sources.txt

# Run tests
invoke_tests "Tools" "Mono"