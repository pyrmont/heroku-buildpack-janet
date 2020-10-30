function indent() {
  c='s/^/       /'
  case $(uname) in
    Darwin) sed -l "$c";;
    *)      sed -u "$c";;
  esac
}

# Outputs log line
#
# Usage:
#
#     output_line "Cloning repository"
#
function output_line() {
  echo "$1" | indent
}

# Outputs section heading
#
# Usage:
#
#     output_section "Application tasks"
#
function output_section() {
  local indentation="----->"
  echo "${indentation} $1"
}

function load_config() {
  output_section "Loading configuration"

  local custom_config_file="${build_path}/janet_buildpack.config"

  # Source for default versions file from buildpack first
  source "${build_pack_path}/janet_buildpack.config"

  if [ -f $custom_config_file ];
  then
    source $custom_config_file
  else
    output_line "WARNING: no janet_buildpack.config in app root"
    output_line "default config in buildpack used"
  fi

  fix_janet_version

  output_section "Configuring versions"
  output_line "- Stack ${STACK}"
  output_line "- Janet ${janet_version}"
}

function export_env_vars() {
  whitelist_regex=${2:-''}
  blacklist_regex=${3:-'^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'}
  if [ -d "$env_path" ]; then
    output_section "Exporting config vars"
    for e in $(ls $env_path); do
      echo "$e" | grep -E "$whitelist_regex" | grep -vE "$blacklist_regex" &&
      export "$e=$(cat $env_path/$e)"
      :
    done
  fi
}

function export_jpm_env() {
  mkdir -p ${build_path}/modules

  export JANET_HEADERPATH=$(janet_path)
  output_line "- JANET_HEADERPATH=$(janet_path)"
  export JANET_LIBPATH=${build_path}/modules
  output_line "- JANET_LIBPATH=${build_path}/modules"
  export JANET_BINPATH=${build_path}/build
  output_line "- JANET_BINPATH=${build_path}/build"
}

function check_stack() {

  if [ "${STACK}" = "cedar" ]; then
    echo "ERROR: cedar stack is not supported, upgrade to cedar-14"
    exit 1
  fi

  if [ ! -f "${cache_path}/stack" ] || [ ! $(cat "${cache_path}/stack") = "${STACK}" ]; then
    output_section "Checking stack"
    output_line "stack changed and rebuild required"
    $(clear_cached_files)
  fi

  echo "${STACK}" > "${cache_path}/stack"
}

function clean_cache() {
  if [ $always_rebuild = true ]; then
    output_section "Cleaning cache"
    $(clear_cached_files)
  fi
}

function clear_cached_files() {
  rm -rf \
    $(janet_path) \
    $(deps_backup_path) \
    $(build_backup_path)
}

function fix_janet_version() {
  # TODO: this breaks if there is an carriage return behind janet_version=(branch master)^M
  if [ ${#janet_version[@]} -eq 2 ] && [ ${janet_version[0]} = "branch" ]; then
    force_fetch=true
    janet_version=${janet_version[1]}

  elif [ ${#janet_version[@]} -eq 1 ]; then
    force_fetch=false

    # If we detect a version string (e.g. 1.14 or 1.14.0) we prefix it with "v"
    if [[ ${janet_version} =~ ^[0-9]+\.[0-9]+ ]]; then
      # strip out any non-digit non-dot characters
      janet_version=$(echo "$janet_version" | sed 's/[^0-9.]*//g')
      janet_version=v${janet_version}
    fi

  else
    output_line "invalid Janet version specified"
    output_line "see the README for allowed formats at:"
    output_line "https://github.com/pyrmont/heroku-buildpack-janet"
    exit 1
  fi
}
