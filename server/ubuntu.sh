#!/bin/bash

# Function for auto-importing common files
auto_import() {
  source "$DIR/../app/common.sh"
  source "$DIR/../app/api_log.sh"
  DIR="$DIR/../app" source "$DIR/../app/api_repos.sh"
}; export -f auto_import

# Get the directory of the script
DIR="$(dirname "$(readlink -f "$0")")"

# TODO: check ARCH of system
ARCH="${ARCH:-amd64}"

# Auto-import common files
auto_import
BUILD_DIR="$1"

# Main constants
UBUNTU_NAME=jammy

# Download raw list of packages
UBUNTU_PKG_LIST_LINK=http://archive.ubuntu.com/ubuntu/dists/$UBUNTU_NAME/main/binary-$ARCH/Packages.gz
UBUNTU_RAW_PKG_LIST_PATH=$BUILD_DIR/Packages
UBUNTU_RAW_PKG_LIST_COMMPRESSED_PATH=$UBUNTU_RAW_PKG_LIST_PATH.gz

if [ ! -s "$UBUNTU_RAW_PKG_LIST_PATH" ]; then
  log::info "Download raw list of packages"
  curl -sL $UBUNTU_PKG_LIST_LINK -o $UBUNTU_RAW_PKG_LIST_COMMPRESSED_PATH
  gzip --decompress --stdout $UBUNTU_RAW_PKG_LIST_COMMPRESSED_PATH > $UBUNTU_RAW_PKG_LIST_PATH
  rm -f $UBUNTU_RAW_PKG_LIST_COMMPRESSED_PATH
fi

# Parse raw list to simple list
UBUNTU_PKG_LIST_PATH=$BUILD_DIR/ubuntu_pkgs

# TODO Wait developer... : )
