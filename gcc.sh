#!/bin/bash -e
################################################################################
##  File:  gcc.sh
##  Desc:  Installs GNU C++
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh


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

function InstallGcc {
    version=$1

    echo "Installing $version..."
    retry_command "apt-get install -y $version"
}

# Install GNU C++ compiler
retry_command "add-apt-repository ppa:ubuntu-toolchain-r/test -y"
retry_command "apt-get update -y"

versions=$(get_toolset_value '.gcc.versions[]')

for version in ${versions[*]}; do
    InstallGcc $version
done

invoke_tests "Tools" "gcc"