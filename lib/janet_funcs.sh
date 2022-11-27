function download_janet() {
  output_section "Fetching Janet"

  # If a previous download does not exist, then always re-download
  if [ ${force_fetch} = true ] || [ ! -f ${cache_path}/$(janet_download_file) ]; then
    clean_janet_downloads
    janet_changed=true
    local download_url="https://github.com/janet-lang/janet/releases/download/${janet_version}/janet-${janet_version}-linux-x64.tar.gz"

    curl -sL ${download_url} -o ${cache_path}/$(janet_download_file) || exit 1
    output_line "${download_url} downloaded"

    git clone --depth=1 https://github.com/janet-lang/jpm.git ${cache_path}/jpm
    output_line "jpm downloaded"
  else
    output_line "Cached file used"
  fi
}

function install_janet() {
  output_section "Installing Janet"

  mkdir -p $(janet_path)
  cd $(janet_path)

  tar xfz ${cache_path}/$(janet_download_file) --strip-components=2
  output_line "Archive unpacked"

  cd - > /dev/null

  chmod +x $(janet_path)/bin/janet
  PATH=$(janet_path)/bin:${PATH}

  export LC_CTYPE=en_US.utf8

  cd ${cache_path}/jpm
  PREFIX=$(janet_path)/ JANET_BINPATH=$(janet_path)/bin janet bootstrap.janet
}

function janet_download_file() {
  echo janet-${janet_version}.tar.gz
}

function clean_janet_downloads() {
  rm -rf ${cache_path}/janet*.gz
  rm -rf ${cache_path}/jpm
}

function janet_changed() {
  if [ $janet_changed = true ]; then
    echo "(changed)"
  fi
}
