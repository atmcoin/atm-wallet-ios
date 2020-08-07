#!/bin/bash
# Downlaods the latest app resource bundles to be embedded

function downloadBundle() {
    bundle_name="$1-staging"
    host="build.just.cash"
    if [[ "$2" == "prod" ]]; then
      bundle_name="$1"
      host="build.just.cash"
    fi
    echo "Downloading ${bundle_name}.tar from ${host}..."
    curl --silent --show-error --output "breadwallet/Resources/${bundle_name}.tar" https://${host}/assets/bundles/${bundle_name}/download
}

plistBuddy="/usr/libexec/PlistBuddy"
plist="breadwallet/Resources/AssetBundles.plist"

bundleNames=($("${plistBuddy}" -c "print" "${plist}" | sed -e 1d -e '$d'))

for bundleName in "${bundleNames[@]}"
do
  downloadBundle ${bundleName}
  downloadBundle ${bundleName} "prod"
done
