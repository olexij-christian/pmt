#!/bin/bash
VERSION="v0.1.0"

# Get the directory of the script
DIR="$(dirname "$(readlink -f "$0")")"

# Import
source $DIR/common.sh
source $DIR/api_os.sh
source $DIR/api_repos.sh

# Function to display usage information
function usage {
  echo "Usage: pmt [options...] <package_manager> <pm_command> [packages...]"
  echo ""
  echo "  PMT (Package Manager Translator) is a command-line tool designed to"
  echo "  facilitate the translation of package names between different package"
  echo "  managers on Linux distributions."
  echo ""
  echo "Options:"
  echo "  -h, --help     Show this message and exit."
  echo "  -v, --version  Show the version information."
  echo "  -n, --dry-run  Translate without installing."
  echo "  -y, --yes      Enable automatic yes to prompts."
  exit 0
}

# Process command line options
while [[ "$1" == -* ]]; do
  case "$1" in
    "-n" | "--dry-run")
      DRY_RUN=yes
      ;;
    "-y" | "--yes")
      ALWAYS_YES=yes
      ;;
    "-v" | "--version")
      echo $VERSION
      exit 0
      ;;
    "-h" | "--help")
      usage
      ;;
    *)
      error "Unsupported flag \"$1\"."
      ;;
  esac

  shift      
done

# Ensure enough arguments are provided
if [ "$#" -lt 3 ]; then
  error "Insufficient arguments. At least 3 arguments are required."
fi

# Set default package manager if not provided
if [ -z "$PM" ]; then
  PM=$__OS_PM_NAME
  if [ -z "$PM" ]; then
    error "Environment variable 'PM' not set. Set it to your OS package manager."
  fi
fi

# TODO: check ARCH of system
ARCH="${ARCH:-amd64}"

# Function to translate package names for installation
function pm_translate {
  local pm1_paths_str
  local pm2_pkgs
  local pkg_to_install

  pm1_paths_str="$(repo::get_paths $pm_name $pkg_name)"
  pm2_pkgs="$(echo "$pm1_paths_str" | sed 's/ /\n/g' | repo::translate_paths_to_pkgs "$PM")"

  if [ "$(echo "$pm2_pkgs" | wc -w)" -gt 1 ]; then
    pkg_to_install=$(echo "$pm2_pkgs" | sed 's/ /\n/g' | gum choose --header "Choose package to install:")
  else
    pkg_to_install=$pm2_pkgs
  fi

  echo "$pkg_to_install"
}

# Create cache directory if not exists
mkdir -p "$__cache_dir"

# Parse command line arguments
pm_name=$1 
pm_cmd=$2 
shift 2

declare -a packages_to_install
while [ "$#" -gt 0 ]; do
  pkg_name=$1

  case "$pm_name" in
    "apt" | "apt-get" | "dnf")
      if [ "$pm_cmd" == "install" ]; then
        packages_to_install+=("$(pm_translate "$pkg_name")")
      fi
      ;;
    *)
      error "Unsupported package manager: $pm_name. Supported managers: apt, apt-get, dnf."
      ;;
  esac

  shift
done

# Install packages
os::pm:cmd_install "${packages_to_install[@]}"
