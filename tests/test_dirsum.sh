#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIRSUM="$PROJECT_ROOT/bin/dirsum"

passed=0
failed=0

TEST_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TEST_DIR"
}

trap cleanup EXIT

assert_contains() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    if [[ "$actual" == *"$expected"* ]]; then
        printf 'PASS: %s\n' "$description"
        ((passed += 1))
    else
        printf 'FAIL: %s\n' "$description" >&2
        printf '  expected output to contain: %s\n' "$expected" >&2
        printf '  actual output: %s\n' "$actual" >&2
        ((failed += 1))
    fi
}

assert_status() {
    local actual="$1"
    local expected="$2"
    local description="$3"

    if [[ "$actual" -eq "$expected" ]]; then
        printf 'PASS: %s\n' "$description"
        ((passed += 1))
    else
        printf 'FAIL: %s\n' "$description" >&2
        printf '  expected status: %s\n' "$expected" >&2
        printf '  actual status: %s\n' "$actual" >&2
        ((failed += 1))
    fi
}

assert_empty() {
    local actual="$1"
    local description="$2"

    if [[ -z "$actual" ]]; then
        printf 'PASS: %s\n' "$description"
        ((passed += 1))
    else
        printf 'FAIL: %s\n' "$description" >&2
        printf '  expected empty output\n' >&2
        printf '  actual output: %s\n' "$actual" >&2
        ((failed += 1))
    fi
}

# Basic directory summary
mkdir "$TEST_DIR/basic"
touch "$TEST_DIR/basic/a.txt"
touch "$TEST_DIR/basic/b.txt"
mkdir "$TEST_DIR/basic/subdir"

output="$("$DIRSUM" "$TEST_DIR/basic")"

assert_contains "$output" "Files: 2" \
    "counts files"

assert_contains "$output" "Directories: 1" \
    "counts directories"

# Empty directory
mkdir "$TEST_DIR/empty"

output="$("$DIRSUM" "$TEST_DIR/empty")"

assert_contains "$output" "Files: 0" \
    "reports zero files for empty directory"

assert_contains "$output" "Directories: 0" \
    "reports zero subdirectories for empty directory"

# Directory path containing spaces
mkdir "$TEST_DIR/directory with spaces"
touch "$TEST_DIR/directory with spaces/example.txt"

output="$("$DIRSUM" "$TEST_DIR/directory with spaces")"

assert_contains "$output" "Files: 1" \
    "handles directory paths containing spaces"

# Help
output="$("$DIRSUM" --help)"
status=$?

assert_status "$status" 0 \
    "--help exits successfully"

assert_contains "$output" "Usage:" \
    "--help prints usage information"

# Version
output="$("$DIRSUM" --version)"
status=$?

assert_status "$status" 0 \
    "--version exits successfully"

assert_contains "$output" "dirsum 0.2.0" \
    "--version reports current version"

# Nonexistent directory
output="$("$DIRSUM" "$TEST_DIR/missing" 2>&1)"
status=$?

assert_status "$status" 1 \
    "returns failure for nonexistent directory"

assert_contains "$output" "does not exist" \
    "explains nonexistent directory error"

# File instead of directory
touch "$TEST_DIR/not-a-directory"

output="$("$DIRSUM" "$TEST_DIR/not-a-directory" 2>&1)"
status=$?

assert_status "$status" 1 \
    "returns failure when given a file"

assert_contains "$output" "is not a directory" \
    "explains file argument error"

# Too many arguments
output="$("$DIRSUM" one two 2>&1)"
status=$?

assert_status "$status" 1 \
    "returns failure for too many arguments"

assert_contains "$output" "too many arguments" \
    "explains excessive arguments"

# Unknown option
output="$("$DIRSUM" --unknown 2>&1)"
status=$?

assert_status "$status" 1 \
    "returns failure for unknown option"

assert_contains "$output" "unknown option" \
    "explains unknown option"

# Verify errors are written to stderr
stdout_file="$TEST_DIR/stdout.txt"
stderr_file="$TEST_DIR/stderr.txt"

"$DIRSUM" "$TEST_DIR/missing" \
    >"$stdout_file" \
    2>"$stderr_file"

status=$?

stdout="$(cat "$stdout_file")"
stderr="$(cat "$stderr_file")"

assert_status "$status" 1 \
    "error written to stderr still returns failure"

assert_empty "$stdout" \
    "errors do not write to stdout"

assert_contains "$stderr" "does not exist" \
    "errors are written to stderr"

# Summary
printf '\n%d passed, %d failed\n' "$passed" "$failed"

if (( failed > 0 )); then
    exit 1
fi