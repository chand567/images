#!/bin/bash -e

################################################################################
##  File:  istioctl.sh
##  Desc:  Installs istioctl
################################################################################

# Source the helpers for use with the script
source "$HELPER_SCRIPTS/etc-environment.sh"
curl -sSL https://istio.io/downloadIstioctl -o downloadIstioctl.sh
bash downloadIstioctl.sh
mv $HOME/.istioctl /opt/
sudo ln -sf "/opt/.istioctl/bin/istioctl" /usr/local/bin/istioctl
prependEtcEnvironmentPath '/opt/.istioctl/bin/'
export PATH=/opt/.istioctl/bin:$PATH
echo "Installation completed successfully."
echo "Installed at: $(which istioctl)"
ls -la "/opt/.istioctl/bin/"

invoke_tests "Tools" "istioctl"