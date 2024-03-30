#!/bin/bash

# Function to get the list of Fedora packages
get_fedora_pkg_list() {
  local url="https://packages.fedoraproject.org"
  local fullurl="$url/index-static.html"
  local selector="p#prefix > a"

  # Download the HTML content
  local html=$(curl -s "$fullurl")

  # Extract hrefs
  local hrefs=$(echo "$html" | pup "$selector" attr{href})

  # Function to scrape URL
  scrape_url() {
    local subpage_html=$(curl -s "$1")
    local result=$(echo "$subpage_html" | pup "li > a" text{})
    echo "$result"
    auto_import && log::debug "Loaded page successfully: $1"
  }

  # Exporting function and executing in parallel
  export -f scrape_url
  echo "$hrefs" | DIR=$DIR xargs -n 1 -P $NUM_THREADS -I {} bash -c "scrape_url $url/{}"
}

# Function for auto-importing common files
auto_import() {
  source "$DIR/../app/common.sh"
  source "$DIR/../app/api_log.sh"
  DIR="$DIR/../app" source "$DIR/../app/api_repos.sh"
}; export -f auto_import

main() {
  # Directory and file paths
  local dir_name="$BUILD_DIR/$__dnf_paths_dir_name"
  local ready_list="$dir_name"ready_list
  local plan_list="$dir_name"plan_list
  local is_list_downloaded="$dir_name"is_list_downloaded

  # Check if pkg list is downloaded, if not, download it
  if [ ! -e "$is_list_downloaded" ]; then
    log::debug "Preparing list of packages in Fedora repository"
    get_fedora_pkg_list > "$plan_list"
  fi

  # Mark that pkg list is downloaded fully
  touch "$is_list_downloaded"

  # Create directory if not exists
  mkdir -p "$dir_name"

  # List downloaded files
  ls "$dir_name" > "$ready_list"

  # Sort files
  sort "$ready_list" | uniq > "$ready_list".sorted
  sort "$plan_list" | uniq > "$plan_list".sorted

  # Function to exported for executing in parallel
  get_data() {
    auto_import
    local data=$(repo::get_path dnf "$(basename "$1")")
    echo "$data" > "$1"
  }; export -f get_data

  # Executing in parallel download only not downloaded files
  comm -23 "$plan_list".sorted "$ready_list".sorted | \
    awk '!/^\t/' | \
    DIR=$DIR xargs -n 1 -P $NUM_THREADS -I {} bash -c "get_data $dir_name/{}"

  # Output directories
  local out_dir_path="$__cache_dir/out_dnf_paths"
  local out_dir_trash="$__cache_dir/out_dnf_trash"

  # Create directories if not exists
  mkdir -p "$out_dir_path" "$out_dir_trash"

  # Move files
  for f in "$dir_name"/*; do
    if [ -f "$__cache_dir/stop" ]; then
      exit 1
    fi
    pkg_name="$(basename "$f")"
    while IFS= read -r line; do
      mkdir -p "$out_dir_path/$(dirname "$line")"
      echo "$pkg_name" >> "$out_dir_path/$line"
    done < "$f"
    mv "$f" "$out_dir_trash"
    echo "$pkg_name successfully loaded"
  done
}

# Get the directory of the script
DIR="$(dirname "$(readlink -f "$0")")"

# Auto-import common files
auto_import
BUILD_DIR="$1"

# Setting default number of threads
NUM_THREADS="${NUM_THREADS:-$(nproc)}"

main
