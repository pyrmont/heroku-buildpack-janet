#! /bin/sh
# file: test/detect_test.sh
. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

test_detect_with_project_file() {
  touch ${BUILD_DIR}/project.janet
  capture detect
  assertCapturedSuccess
  assertCaptured "Janet"
}

# test_detect_with_no_project_file() {
#   capture detect
#   assertCapturedError
#   assertCaptured "no"
# }
