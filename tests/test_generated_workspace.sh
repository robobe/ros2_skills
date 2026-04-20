#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <workspace_path> <prefix>" >&2
  exit 2
fi

workspace_path=$1
prefix=$2
src_dir="$workspace_path/src"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_dir() {
  local path=$1
  [[ -d "$path" ]] || fail "missing directory: $path"
}

assert_no_dir() {
  local path=$1
  [[ ! -d "$path" ]] || fail "unexpected directory exists: $path"
}

assert_file() {
  local path=$1
  [[ -f "$path" ]] || fail "missing file: $path"
}

assert_contains() {
  local needle=$1
  local path=$2
  grep -Fq "$needle" "$path" || fail "expected '$needle' in $path"
}

assert_not_contains() {
  local needle=$1
  local path=$2
  if grep -Fq "$needle" "$path"; then
    fail "unexpected '$needle' found in $path"
  fi
}

assert_dir "$workspace_path"
assert_dir "$src_dir"

description_pkg="$src_dir/${prefix}_description"
gazebo_pkg="$src_dir/${prefix}_gazebo"
bringup_pkg="$src_dir/${prefix}_bringup"
application_pkg="$src_dir/${prefix}_application"

assert_dir "$description_pkg"
assert_dir "$gazebo_pkg"
assert_dir "$bringup_pkg"
assert_dir "$application_pkg"

assert_dir "$description_pkg/urdf"
assert_dir "$description_pkg/meshes"
assert_dir "$description_pkg/models"
assert_no_dir "$description_pkg/src"
assert_no_dir "$description_pkg/include"

assert_dir "$gazebo_pkg/worlds"

assert_dir "$bringup_pkg/launch"
assert_dir "$bringup_pkg/config"
assert_no_dir "$bringup_pkg/src"
assert_no_dir "$bringup_pkg/include"

assert_dir "$application_pkg/src"
assert_dir "$application_pkg/include/${prefix}_application"
assert_no_dir "$application_pkg/launch"
assert_no_dir "$application_pkg/config"

assert_file "$bringup_pkg/launch/gz.launch.yaml"
assert_file "$bringup_pkg/config/bridge.yaml"
assert_file "$workspace_path/env.sh"
assert_file "$workspace_path/colcon_defaults.yaml"

assert_not_contains "<prefix>" "$bringup_pkg/launch/gz.launch.yaml"
assert_contains "$(printf '%s_bringup' "$prefix")" "$bringup_pkg/launch/gz.launch.yaml"
assert_contains "$(printf '%s_gazebo' "$prefix")" "$bringup_pkg/launch/gz.launch.yaml"

for package_xml in \
  "$description_pkg/package.xml" \
  "$gazebo_pkg/package.xml" \
  "$bringup_pkg/package.xml" \
  "$application_pkg/package.xml"
do
  assert_file "$package_xml"
  assert_contains "<version>0.0.1</version>" "$package_xml"
done

assert_contains "install(DIRECTORY launch config" "$bringup_pkg/CMakeLists.txt"
assert_contains "install(DIRECTORY worlds" "$gazebo_pkg/CMakeLists.txt"
assert_contains "install(DIRECTORY urdf meshes models" "$description_pkg/CMakeLists.txt"
assert_contains "find_package(ament_cmake_python REQUIRED)" "$application_pkg/CMakeLists.txt"
assert_contains 'ament_python_install_package(${PROJECT_NAME})' "$application_pkg/CMakeLists.txt"
assert_contains "DESTINATION lib/\${PROJECT_NAME}" "$application_pkg/CMakeLists.txt"

echo "PASS: generated workspace matches expected skill output"
