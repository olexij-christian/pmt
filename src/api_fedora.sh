# TODO: should refactoring
function repo::dnf:fedora:path {

  process_node() {
    local node="$1"

    # cd ..
    if [ -z "$node" ]; then
      prefix=$(dirname "$prefix")

    # directory
    elif [[ "${node: -1}" == "/" ]]; then
      if [[ "${prefix: -1}" == "/" ]]; then
        prefix="$prefix$node"
      else
        prefix="$prefix/$node"
      fi

    # file
    else
      if [[ "${prefix: -1}" != "/" ]]; then
        prefix="$prefix/"
      fi

      echo "$prefix$node"
    fi
  }

  # if has problem when install pkg link then reinstall
  try_num=0
  update_pkg_link() {
    query_page_data=$(curl -s $query_url) # query page
    pkg_link=$(echo "$query_page_data" | pup ".stretched-link" attr{href} | head -n 1) # get first result of searching

    # TODO: returns warns ONLY when get server error
    if [ -z "$pkg_link" ]; then
      log::warn "Problem when download page for information about package, so retry: $target query_url=$query_url "
      ((try_num++))
      if [ "$try_num" -lt 5 ]; then
        update_pkg_link
      else
        log::error "Problem when try download page for information about package: $target"
      fi
    fi

    found_pkg_name="$(basename "$pkg_link")"
    if [ "$found_pkg_name" != "$target" ]; then
      log::error "Package $target is not found in repository"
    fi
  }

  throw_error=true
  try_num=0
  try_download_data() {
    for version in "${__repo_version_fedora_list[@]}"; do

      url="$__repo_path_fedora$pkg_link/$version" 
      data_page=$(curl -s "$url")

      # example error 404
      successfully_load=$(echo "$data_page" | pup ".container")
      if [ -n "$successfully_load" ]; then
        throw_error=false
      fi

      data=$(echo "$data_page" | awk '/<div class="tree">/,/<\/div>/' | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//;s/[ \t]*$//')

      if [ -n "$data" ]; then
        break
      fi

    done

    # NOTE: if .container is not exists then has some nginx error from example 404
    if [ "$throw_error" = true ]; then
      log::warn "Problem when download page for package, so retry: $target url=$url"
      ((try_num++))
      if [ "$try_num" -lt 5 ]; then
        try_download_data
      else
        log::error "Cannot to download page for package: $target url=$url"
      fi
    fi
  }

  target=$1

  query_url="https://packages.fedoraproject.org/search?query=$target"

  update_pkg_link

  # TODO: in this loop search package in every repo
  # in future plans finding connected repository
  # in system by dnf
  try_download_data

  log::debug "successfully downloaded for package: $target" #if-used: DEBUG

  data="${data#"${data%%[![:space:]]*}"}"
  data="${data%"${data##*[![:space:]]}"}"

  IFS=$'\n'
  prefix=""
  while IFS= read -r line; do
      # Видалення тегів та обробка вузлів
      process_node "$line"
  done <<< "$data"
}
