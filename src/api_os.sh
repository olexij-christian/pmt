declare -A _os_pm_names
_os_pm_names["fedora"]="dnf"
_os_pm_names["debian"]="apt-get"
_os_pm_names["ubuntu"]="apt"
_os_pm_names["devuan"]="apt"

function os::name {
  echo $(grep -w ID /etc/os-release | cut -d= -f2 | tr -d '"')
}; __OS_NAME=$(os::name)

function os::pm:name {
  local pm_name=${_os_pm_names["$__OS_NAME"]}
  if [ -n "$PM" ]; then
    echo $PM
  elif [ -n "$pm_name" ]; then
    echo $pm_name
  else 
    return 1
  fi
}; __OS_PM_NAME=$(os::pm:name)


declare -A _os_pm_cmd_install
_os_pm_cmd_install["dnf"]="install"
_os_pm_cmd_install["apt"]="install"
_os_pm_cmd_install["apt-get"]="install"

declare -A _os_pm_cmd_install_prefix
_os_pm_cmd_install_prefix["dnf"]="sudo"
_os_pm_cmd_install_prefix["apt"]="sudo"
_os_pm_cmd_install_prefix["apt-get"]="sudo"
function os::pm:cmd_install {
  local prefix_sudo="${_os_pm_cmd_install_prefix[$__OS_PM_NAME]}"
  local cmd_install="${_os_pm_cmd_install[$__OS_PM_NAME]}"
  if [ -z $cmd_install ]; then
    error "Information about package manager $__PS_PM_NAME is not provided"
  fi
  local result_command="$prefix_sudo $__OS_PM_NAME $cmd_install $@" # Example: sudo apt install i3-wm bash
  info "Will execute command: $result_command"
  if [ -z "$DRY_RUN" ]; then
    if [ -n "$ALWAYS_YES" ]; then
      $result_command
    else
      gum confirm "Execute command that install packages?" && $result_command
    fi
  fi
}
