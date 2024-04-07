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
UBUNTU_RAW_PKG_LIST=$BUILD_DIR/ubuntu_raw_list
UBUNTU_RAW_PKG_LIST_COMMPRESSED=$UBUNTU_RAW_PKG_LIST.gz

if [ ! -s "$UBUNTU_RAW_PKG_LIST" ]; then
  log::info "Download raw list of packages"
  curl -sL $UBUNTU_PKG_LIST_LINK -o $UBUNTU_RAW_PKG_LIST_COMMPRESSED
  gzip --decompress --stdout $UBUNTU_RAW_PKG_LIST_COMMPRESSED > $UBUNTU_RAW_PKG_LIST
  rm -f $UBUNTU_RAW_PKG_LIST_COMMPRESSED
fi

# Split raw file to (one file) is (one package)
UBUNTU_PKG_RAW_LIST_DIR=$BUILD_DIR/ubuntu_raw_pkgs
log::info "Split raw data"
rm -rf $UBUNTU_PKG_RAW_LIST_DIR
mkdir $UBUNTU_PKG_RAW_LIST_DIR
perl -00ne "open(F, \">$UBUNTU_PKG_RAW_LIST_DIR/output$.txt\"); print F \$_; close(F)" $UBUNTU_RAW_PKG_LIST

# Generate list of pkgs
UBUNTU_PKG_LIST=$BUILD_DIR/ubuntu_pkgs
rm -f $UBUNTU_PKG_LIST
for raw_pkg_info in "$UBUNTU_PKG_RAW_LIST_DIR/*"; do
  cat $raw_pkg_info | grep -Po '(?<=Package: )\S+' >> $UBUNTU_PKG_LIST
done

# Generate paths of pkgs with name of every pkg
UBUNTU_PATHS=$BUILD_DIR/ubuntu_paths
rm -rf $UBUNTU_PATHS
mkdir $UBUNTU_PATHS

# TODO Wait developer... : )
