function restore_app() {
  if [ -d $(deps_backup_path) ]; then
    mkdir -p ${build_path}/modules
    cp -pR $(deps_backup_path)/. ${build_path}/modules
  fi

  if [ $janet_changed != true ]; then
    if [ -d $(build_backup_path) ]; then
      mkdir -p ${build_path}/build
      cp -pR $(build_backup_path)/. ${build_path}/build
    fi
  fi
}

function app_dependencies() {
  # Unset this var so that if the parent dir is a git repo, it isn't detected
  # And all git operations are performed on the respective repos
  local git_dir_value=$GIT_DIR
  unset GIT_DIR

  cd $build_path
  output_section "Installing dependencies"
  if [ -f "lockfile.jdn" ]; then
    jpm load-loadfile | indent
  else
    jpm deps | indent
  fi

  export GIT_DIR=$git_dir_value
  cd - > /dev/null
}


function backup_app() {
  # Delete the previous backups
  rm -rf $(deps_backup_path) $(build_backup_path)

  mkdir -p $(deps_backup_path) $(build_backup_path)

  if [ -d "${build_path}/modules" ]; then
    cp -pR ${build_path}/modules/. $(deps_backup_path)
  fi

  if [ -d "${build_path}/build" ]; then
    cp -pR ${build_path}/build/. $(build_backup_path)
  fi
}


function compile_app() {
  local git_dir_value=$GIT_DIR
  unset GIT_DIR

  cd $build_path
  output_section "Building artifacts"

  jpm build | indent

  export GIT_DIR=$git_dir_value
  cd - > /dev/null
}
