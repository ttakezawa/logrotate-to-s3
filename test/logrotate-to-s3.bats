#!/usr/bin/env bats

TEST_DIR=$(mktemp -d)

setup() {
  mkdir -p "$TEST_DIR"
}

teardown() {
   [[ -d "$TEST_DIR" ]] && rm -rf "$TEST_DIR"
}

@test "process normal paths" {
  bucket=test-bucket
  test_dir=$TEST_DIR

  file1="${test_dir}/test1.log"
  file2="${test_dir}/test2.log"
  echo test1 > "${file1}.1"
  echo test2 > "${file2}.1"

  UPLOAD_CMD="echo" run logrotate-to-s3 "$bucket" "$file1" "$file2"

  [ "$status" -eq 0 ]
  [ $(expr "${lines[0]}" : ".*$(basename "$file1").1.gz s3://${bucket}/logrotate/$(hostname)/$(date '+%Y/%m')/$(basename "$file1").$(date '+%Y%m')[0-9-]*.gz$") -ne 0 ]
  [ $(expr "${lines[1]}" : ".*$(basename "$file2").1.gz s3://${bucket}/logrotate/$(hostname)/$(date '+%Y/%m')/$(basename "$file2").$(date '+%Y%m')[0-9-]*.gz$") -ne 0 ]
}

@test "process space included paths" {
  bucket=test-bucket
  test_dir="${TEST_DIR}/aa bb"

  mkdir -p "$test_dir"

  file1="${test_dir}/test 1.log"
  file2="${test_dir}/test 2.log"
  echo test1 > "${file1}.1"
  echo test2 > "${file2}.1"

  UPLOAD_CMD="echo" run logrotate-to-s3 "$bucket" "$file1" "$file2"

  [ "$status" -eq 0 ]
  [ $(expr "${lines[0]}" : ".*$(basename "$file1").1.gz s3://${bucket}/logrotate/$(hostname)/$(date '+%Y/%m')/$(basename "$file1").$(date '+%Y%m')[0-9-]*.gz$") -ne 0 ]
  [ $(expr "${lines[1]}" : ".*$(basename "$file2").1.gz s3://${bucket}/logrotate/$(hostname)/$(date '+%Y/%m')/$(basename "$file2").$(date '+%Y%m')[0-9-]*.gz$") -ne 0 ]
}

@test "process gzipped paths" {
  bucket=test-bucket
  test_dir=$TEST_DIR

  file="${test_dir}/test.log"
  echo test > "${file}.1.gz"

  UPLOAD_CMD="echo" run logrotate-to-s3 "$bucket" "$file"

  [ "$status" -eq 0 ]
  [ $(expr "${lines[0]}" : ".*$(basename "$file").1.gz s3://${bucket}/logrotate/$(hostname)/$(date '+%Y/%m')/$(basename "$file").$(date '+%Y%m')[0-9-]*.gz$") -ne 0 ]
}
