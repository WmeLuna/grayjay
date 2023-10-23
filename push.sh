#!/bin/bash

# Function to create Git tag and GitHub release
create_release() {
  local version=$1
  local files=$2
  local prerelease_flag=$3
  local base_url="https://releases.grayjay.app/"

  # Check if tag already exists
  if git rev-parse $version >/dev/null 2>&1; then
    echo "Tag $version already exists. Skipping."
    return
  fi

  # Create and push a Git tag
  git tag -a $version -m "Release $version"
  git push origin $version

  # Download files
  IFS=',' read -ra ADDR <<< "$files"
  for i in "${ADDR[@]}"; do
    curl -sLO "${base_url}${i}"
  done

  # Create a GitHub release and upload the files
  gh release create $version $files --title "Release $version" $prerelease_flag

  # Cleanup downloaded files
  rm -f $files
}

# Fetch current stable and unstable versions
stableVer=$(curl -sL "https://releases.grayjay.app/version.txt")
unstableVer=$(curl -sL "https://releases.grayjay.app/version-unstable.txt")

# Files to download and upload for each release
stableFiles="app-x86_64-release.apk,app-arm64-v8a-release.apk,app-armeabi-v7a-release.apk,app-universal-release.apk,app-x86-release.apk,app-release.apk"
unstableFiles="app-x86_64-release-unstable.apk,app-arm64-v8a-release-unstable.apk,app-armeabi-v7a-release-unstable.apk,app-universal-release-unstable.apk,app-x86-release-unstable.apk,app-release-unstable.apk"

# Create stable release
create_release $stableVer $stableFiles ""

# Create unstable pre-release
create_release $unstableVer $unstableFiles "--prerelease"