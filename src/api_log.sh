function log::error {
  gum log -l error $1
  exit 1
}

function log::info {
  gum log -l info $1
}

function log::warn {
  gum log -l warn $1
}

function log::debug {
  if [ -n "$DEBUG" ]; then
    gum log -l debug $1
  fi
}
