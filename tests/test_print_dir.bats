#!/usr/bin/env bats
setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/sub"
  mkdir -p "$TEST_DIR/node_modules"
  echo "hello" > "$TEST_DIR/file1.txt"
  echo "world" > "$TEST_DIR/sub/file2.log"
  echo "secret" > "$TEST_DIR/.env"
  echo "ignored" > "$TEST_DIR/node_modules/module.js"
  SCRIPT="$(pwd)/scripts/print-dir.sh"
}

teardown() { rm -rf "$TEST_DIR"; }

@test "prints all files with headers" {
  run "$SCRIPT" "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" =~ file1.txt ]]
  [[ "$output" =~ file2.log ]]
}

@test "respects max depth" {
  run "$SCRIPT" -d 1 "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" =~ file1.txt ]]
  [[ ! "$output" =~ file2.log ]]
}

@test "includes only matching pattern" {
  run "$SCRIPT" -i '*.txt' "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" =~ file1.txt ]]
  [[ ! "$output" =~ file2.log ]]
}

@test "excludes matching pattern" {
  run "$SCRIPT" -e '*.log' "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" =~ file1.txt ]]
  [[ ! "$output" =~ file2.log ]]
}

@test "skips sensitive files" {
  run "$SCRIPT" -s "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ .env ]]
}

@test "skips large files (human readable)" {
  head -c 2097152 </dev/urandom > "$TEST_DIR/large.txt"
  run "$SCRIPT" -m 1MB "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ large.txt ]]
}

@test "excludes directories by default" {
  run "$SCRIPT" "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ module.js ]]
}

@test "excludes directories with -x" {
  mkdir -p "$TEST_DIR/custom"
  echo "data" > "$TEST_DIR/custom/file.txt"
  run "$SCRIPT" -x "custom" "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ ! "$output" =~ file.txt ]]
}
