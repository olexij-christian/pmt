# Get the directory of the script
DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/common.sh
source $DIR/api_log.sh
source $DIR/api_repos.sh

# TODO should refactoring

if [ -z "$NUM_THREADS" ]; then
  NUM_THREADS="$(nproc)"
fi

_dir_name="$__dnf_paths_dir_name"
_ready_list="$__dnf_paths_dir_name"_ready_list
_plan_list="$_fedora_path_dir_name"_plan_list

get_data() {
  data=$(repo::get_path dnf $(basename $1))
  echo "$data" > "$1"
}

mkdir -p $_dir_name

if [ ! -e "fedora_pkg_list" ]; then
  log::debug "Prepare list of packages in repository of fedora"
  bash get_fedora_pkg_list.sh > "$_plan_list"
fi

# list of downloaded files
ls "$__dnf_paths_dir_name" > "$_ready_list"

# sort for command comm
sort "$_ready_list" | uniq > "$_ready_list".sorted
sort "$_plan_list" | uniq > "$_plan_list".sorted

# filter downloaded files then download least
export -f get_data
comm -23 "$_plan_list".sorted "$_ready_list".sorted | awk '!/^\t/' | xargs -n 1 -P $NUM_THREADS -I {} bash -c "get_data $_dir_name/{}"

#TODO: move consts
out_dir_path="$__cache_dir/out_dnf_paths"
out_dir_trash="$__cache_dir/out_dnf_trash"

mkdir -p $out_dir_path $out_dir_trash

for f in "$__dnf_paths_dir_path"/*; do
  if [ -f "$__cache_dir/stop" ]; then
    exit 1
  fi
  pkg_name="$(basename $f)"
  while IFS= read -r line; do
    mkdir -p "$out_dir_path/$(dirname $line)"
    echo $pkg_name >> "$out_dir_path/$line"
  done < "$f"
  mv $f $out_dir_trash
  echo "$pkg_name successfully loaded"
done

# cat fedora_pkg_list | while IFS= read -r line; do
#   get_data $line
# done

