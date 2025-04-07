#!/bin/bash -e
################################################################################
##  File:  oc.sh
##  Desc:  Installs the OC CLI
################################################################################

source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh

# Install the oc CLI
if isUbuntu20; then
    toolset_version=$(get_toolset_value '.ocCli.version')
    DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/$toolset_version/openshift-client-linux-$toolset_version.tar.gz"
else 
DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz"
fi

PACKAGE_TAR_NAME="oc.tar.gz"
download_with_retries $DOWNLOAD_URL "/tmp" $PACKAGE_TAR_NAME
tar xzf "/tmp/$PACKAGE_TAR_NAME" -C "/usr/local/bin" oc

invoke_tests "CLI.Tools" "OC CLI"