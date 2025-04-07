#!/bin/bash -e
################################################################################
##  File:  kotlin.sh
##  Desc:  Installs Kotlin
################################################################################

source $HELPER_SCRIPTS/install.sh

KOTLIN_ROOT="/usr/share"
downloadUrl=$(get_github_package_download_url "JetBrains/kotlin" "contains(\"kotlin-compiler\") and endswith(\".zip\")" "2.1.10")
download_with_retries "$downloadUrl" "/tmp"

unzip -qq /tmp/kotlin-compiler*.zip -d $KOTLIN_ROOT
rm $KOTLIN_ROOT/kotlinc/bin/*.bat
ln -sf $KOTLIN_ROOT/kotlinc/bin/* /usr/bin

invoke_tests "Tools" "Kotlin"
