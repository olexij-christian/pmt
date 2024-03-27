# TODO should refactoring

# TODO add support XDG
__cache_dir="$HOME/.cache/pmt"

__repo_version_debian="bookworm"
__repo_path_debian="https://packages.debian.org/$__repo_version_debian/"
__repo_pkg_debian="https://packages.debian.org/search?searchon=contents&mode=path&suite=stable&arch=any&keywords="

# TODO prepare for conecting Ubuntu repositories
# __repo_version_ubuntu="jammy"
# __repo_path_ubuntu="https://packages.ubuntu.com/$__repo_version_ubuntu/"
# __repo_pkg_ubuntu="https://packages.ubuntu.com/search?searchon=contents&mode=path&suite=stable&arch=any&keywords="

__repo_version_fedora_list=( "fedora-rawhide.html" "fedora-38.html" "fedora-38-updates.html" "fedora-39.html" "fedora-39-updates.html" "fedora-40.html" "epel-7.html" "epel-7-testing.html" "epel-8.html" "epel-9.html" )
__repo_path_fedora="https://packages.fedoraproject.org"
__repo_pkg_fedora="https://raw.githubusercontent.com/olexij-christian/dnf_paths/main/paths"
__dnf_paths_dir_name="dnf_paths"
__dnf_paths_url="https://github.com/olexij-christian/dnf_paths/releases/download/default/dnf_paths.tar.gz"
__dnf_paths_dir_path="$__cache_dir/$__dnf_paths_dir_name"

function error {
  gum log -l error $1
  exit 1
}

info() {
  gum log -l info $1
}

warn() {
  gum log -l warn $1
}

debug() {
  gum log -l debug $1
}
