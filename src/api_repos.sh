
# stdin is list if paths of package in first pm
function repo::translate_paths_to_pkgs {
  local pm2_name="$1"
  
  # get setdin
  while read path; do
    local pkg_name_list="$(repo::get_pkgs "$pm2_name" "$path" 2> /dev/null)"
    if [[ "$pkg_name_list" == "" && ("$path" == *".so" || "$path" == *".h") ]]; then
      pkg_name_list="$(repo::get_paths "$pm2_name" "$(basename "$path")" 2> /dev/null)"
    fi
    if [ "$pkg_name_list" != "" ]; then
      echo "$pkg_name_list"
      break
    fi
  done
}

function repo::get_pkgs {
  local pm=$1 # apt, dnf and so on
  local path=$2 # Example: /usr/bin/bash

  case "$pm" in
    "apt" | "apt-get")
        echo -n $(repo::apt:pkg $path) 
      ;;
    "dnf")
        echo -n $(repo::dnf:pkg $path)
      ;;
    *)
      log::error "Undefined package manager $pm. Can use apt or dnf."
      ;;
  esac
}

function repo::get_paths {
  local pm=$1 # apt, dnf and so on
  local pkg_name=$2 # Example: qt6-base-dev

  case "$pm" in
    "apt" | "apt-get")
        # TODO print warning about null byte, fix it
        echo -n "$(repo::apt:path $pkg_name)"
      ;;
    "dnf")
        echo -n "$(repo::dnf:path $pkg_name)"
      ;;
    *)
      log::error "Undefined package manager $pm. Can use apt or dnf."
      ;;
  esac
}

function repo::apt:pkg {
  path_from_pkg=$1
  html=$(curl -s "$__repo_pkg_debian$path_from_pkg")
  link_pkg=$(echo "$html" | grep -oP '<a\s+[^>]*\bhref="/'"$__repo_version_debian"'[^"]*"[^>]*>\K.*?(?=<\/a>)')

  echo "$link_pkg" | head -n 1 # NOTE: get only first founded path with pkg name
}

function repo::apt:path {
  pkg_name=$1
  full_link_list_files="$__repo_path_debian$ARCH/$pkg_name/filelist"
  html=$(curl -s "$full_link_list_files")

  echo "$html" | grep -Pzo '(?s)<div id="pfilelist">.*?</pre>' | sed 's/<[^>]*>//g'
}

function repo::dnf:pkg {
  path_from_pkg=$1
  if [ "${path_from_pkg:0:1}" == "/" ]; then 
    pkg_name_list=$(curl -s "$__repo_pkg_fedora$path_from_pkg")
  else
    repo::dnf:pkg:cache:auto_prepare
    pkg_name_list=$(grep --color=never $path_from_pkg $__dnf_paths_dir_path | xargs -I {} curl -s "$__repo_pkg_fedora{}" | uniq)
  fi

  if [ "$pkg_name_list" == "404: Not Found" ]; then
    log::error "Cannot find path in repository: path=$path_from_pkg"
  else
    echo $pkg_name_list
  fi
}

function repo::dnf:pkg:cache:auto_prepare {
  if [ ! -e $__dnf_paths_dir_path ]; then
    log::info "Prepare cache for fedora repository" 
    repo::dnf:pkg:cache:prepare
  fi
}

function repo::dnf:pkg:cache:prepare {
  archive_path=${__dnf_paths_dir_path}.tar.gz
  gum spin --title "Downloading" -- curl -L $__dnf_paths_url -o $archive_path
  gum spin --title "Extracting" -- tar -xzvf $archive_path -C $__cache_dir
}

source $DIR/api_fedora.sh
function repo::dnf:path {
  pkg_name=$1
  repo::dnf:fedora:path $pkg_name
}
