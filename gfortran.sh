#!/bin/bash -e
################################################################################
##  File:  gfortran.sh
##  Desc:  Installs GNU Fortran
################################################################################
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh


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

function InstallFortran {
    version=$1

    echo "Installing $version..."
    retry_command "apt-get install -y $version"
}

# Install GNU Fortran compiler
retry_command "add-apt-repository ppa:ubuntu-toolchain-r/test -y"
retry_command "apt-get update -y"

versions=$(get_toolset_value '.gfortran.versions[]')

for version in ${versions[*]}
do
    InstallFortran $version
done

invoke_tests "Tools" "gfortran"