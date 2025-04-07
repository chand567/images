#!/bin/bash -e
################################################################################
##  File:  sqlpackage.sh
##  Desc:  Install SqlPackage CLI to DacFx (https://docs.microsoft.com/sql/tools/sqlpackage/sqlpackage-download#get-sqlpackage-net-core-for-linux)
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

# Install libssl1.1 dependency
if isUbuntu22; then
    export libssl_dep=libssl1.1_1.1.1f-1ubuntu2.22_amd64.deb
    download_with_retries "http://security.ubuntu.com/ubuntu/pool/main/o/openssl/$libssl_dep" "/tmp"
    dpkg -i /tmp/$libssl_dep
fi

# Install SqlPackage
download_with_retries "https://aka.ms/sqlpackage-linux" "." "sqlpackage.zip"

unzip -qq sqlpackage.zip -d /usr/local/sqlpackage
rm -f sqlpackage.zip
chmod +x /usr/local/sqlpackage/sqlpackage
ln -sf /usr/local/sqlpackage/sqlpackage /usr/local/bin

invoke_tests "Tools" "SqlPackage"
