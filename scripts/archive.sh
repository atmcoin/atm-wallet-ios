#!/bin/bash


# check for config file
if [ ! -f $PWD/build/exportOptions.plist ]; then
	mkdir -pv $PWD/build
	cp $PWD/.circleci/config/exportOptions.plist $PWD/build/exportOptions.plist
fi

# use xcpretty if available for improved build output formatting
xcpretty="xcpretty"
command -v xcpretty >/dev/null 2>&1 || { xcpretty="cat"; echo >&2 "WARNING: xcpretty not found. Install with 'gem install xcpretty' for improved build output."; }

scheme=$1

if [[ -n "$scheme" ]]; then
  archive_path="$PWD/build/"$scheme".xcarchive"
  # clean and archive the specified scheme
  xcodebuild -workspace breadwallet.xcworkspace -scheme "$scheme" clean
  xcodebuild -workspace breadwallet.xcworkspace -scheme "$scheme"
  # export and upload to App Store Connect
#  xcodebuild -exportArchive -archivePath "$archive_path" -exportOptionsPlist $PWD/build/exportOptions.plist -exportPath $PWD/build | $xcpretty
else
    echo "Usage: archive.sh <scheme>"
    echo "Available schemes:"
    #xcodebuild -workspace breadwallet.xcworkspace -list
    xcodebuild -project breadwallet.xcodeproj -list
fi
