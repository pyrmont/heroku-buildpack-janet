#! /bin/sh
# file: test/detect_test.sh
. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testDetectWithProjectFile() {
  touch ${BUILD_DIR}/project.janet
  capture detect
  assertCapturedSuccess
  assertCaptured "Janet"
}

testDetectWithNoProjectFile() {
  capture detect
  assertCapturedError
  assertCaptured "no"
}
