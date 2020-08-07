#!/bin/bash
# Downlaods the latest currencies list to be embedded
filename="currencies.json"
host="build.just.cash"
echo "Downloading ${filename} from ${host}..."
curl --silent --show-error --output "breadwallet/Resources/${filename}" https://${host}/currencies
