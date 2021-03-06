list_dependencies() {
  local build_dir="$1"

  cd "$build_dir"
  if $YARN; then
    echo ""
    (yarn list --depth=0 || true) 2>/dev/null
    echo ""
  else
    (npm ls --depth=0 | tail -n +2 || true) 2>/dev/null
  fi
}

run_if_present() {
  local script_name=${1:-}
  local has_script=$(read_json "$BUILD_DIR/package.json" ".scripts[\"$script_name\"]")
  if [ -n "$has_script" ]; then
    if $YARN; then
      echo "Running $script_name (yarn)"
      yarn run "$script_name"
    else
      echo "Running $script_name"
      npm run "$script_name" --if-present
    fi
  fi
}

npm_overloaded_registry() {
  echo "Installing by npm with forced registry because of https://github.com/yarnpkg/yarn/issues/1148"

  npm i basscss-align --registry=https://registry.npmjs.org/
  npm i basscss-border --registry=https://registry.npmjs.org/
  npm i basscss-flexbox --registry=https://registry.npmjs.org/
  npm i basscss-grid --registry=https://registry.npmjs.org/
  npm i basscss-hide --registry=https://registry.npmjs.org/
  npm i basscss-layout --registry=https://registry.npmjs.org/
  npm i basscss-margin --registry=https://registry.npmjs.org/
  npm i basscss-padding --registry=https://registry.npmjs.org/
  npm i basscss-position --registry=https://registry.npmjs.org/
  npm i basscss-type-scale --registry=https://registry.npmjs.org/
  npm i basscss-typography --registry=https://registry.npmjs.org/
  
  # css-framework used to be a private package :)
  npm i css-framework --registry https://repo.fury.io/dagen-niger/
  npm i --unsafe-perm --production --registry=https://registry.npmjs.org/ 2>&1
}

yarn_node_modules() {
  local build_dir=${1:-}

  echo "Installing node modules (yarn.lock)"
  cd "$build_dir"
  yarn install --pure-lockfile --ignore-engines 2>&1
}

npm_node_modules() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir

    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing node modules (package.json + shrinkwrap)"
    else
      echo "Installing node modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}

npm_rebuild() {
  local build_dir=${1:-}

  if [ -e $build_dir/package.json ]; then
    cd $build_dir
    echo "Rebuilding any native modules"
    npm rebuild 2>&1
    if [ -e $build_dir/npm-shrinkwrap.json ]; then
      echo "Installing any new modules (package.json + shrinkwrap)"
    else
      echo "Installing any new modules (package.json)"
    fi
    npm install --unsafe-perm --userconfig $build_dir/.npmrc 2>&1
  else
    echo "Skipping (no package.json)"
  fi
}
