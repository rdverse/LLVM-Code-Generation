#!/usr/bin/env bash

# LLVM Environment Smoke Test
# Usage: source ./llvm_env.sh && ./smoke_test.sh
#
# Quick verification that LLVM environment is working correctly.
# All tests should pass if the environment is properly set up.

set -euo pipefail

echo "=== LLVM Environment Smoke Test ==="
echo

_test_count=0
_pass_count=0

# Helper functions
_test() {
  local test_name="$1"
  local test_cmd="$2"
  _test_count=$((_test_count + 1))
  
  echo -n "${_test_count}. ${test_name}: "
  
  if eval "${test_cmd}" >/dev/null 2>&1; then
    echo "✓ PASS"
    _pass_count=$((_pass_count + 1))
    return 0
  else
    echo "✗ FAIL"
    return 1
  fi
}

_test_with_output() {
  local test_name="$1"
  local test_cmd="$2"
  _test_count=$((_test_count + 1))
  
  echo "${_test_count}. ${test_name}:"
  
  if eval "${test_cmd}" 2>/dev/null; then
    echo "   ✓ PASS"
    _pass_count=$((_pass_count + 1))
    return 0
  else
    echo "   ✗ FAIL"
    return 1
  fi
}

# Test 1: Environment Variables
echo "Environment Variables:"
[ -n "${REPO_ROOT:-}" ] && echo "   REPO_ROOT=${REPO_ROOT}" || echo "   REPO_ROOT=<unset>"
[ -n "${LLVM_SRC:-}" ] && echo "   LLVM_SRC=${LLVM_SRC}" || echo "   LLVM_SRC=<unset>"
[ -n "${LLVM_BIN:-}" ] && echo "   LLVM_BIN=${LLVM_BIN}" || echo "   LLVM_BIN=<unset>"
[ -n "${LLVM_TEST_SUITE_SRC:-}" ] && echo "   LLVM_TEST_SUITE_SRC=${LLVM_TEST_SUITE_SRC}" || echo "   LLVM_TEST_SUITE_SRC=<unset>"
[ -n "${LLVM_TEST_BUILD:-}" ] && echo "   LLVM_TEST_BUILD=${LLVM_TEST_BUILD}" || echo "   LLVM_TEST_BUILD=<unset>"
echo

# Test 2: Directory Existence
_test "REPO_ROOT exists" '[ -d "${REPO_ROOT:-}" ]'
_test "LLVM_SRC exists (if set)" '[ -z "${LLVM_SRC:-}" ] || [ -d "${LLVM_SRC}" ]'
_test "LLVM_BIN exists (if set)" '[ -z "${LLVM_BIN:-}" ] || [ -d "${LLVM_BIN}" ]'
_test "LLVM_TEST_SUITE_SRC exists (if set)" '[ -z "${LLVM_TEST_SUITE_SRC:-}" ] || [ -d "${LLVM_TEST_SUITE_SRC}" ]'
_test "LLVM_TEST_BUILD exists (if set)" '[ -z "${LLVM_TEST_BUILD:-}" ] || [ -d "${LLVM_TEST_BUILD}" ]'
echo

# Test 3: Tool Availability
_test "clang available" 'command -v clang'
_test "FileCheck available" 'command -v FileCheck'
_test "llvm-lit available" 'command -v llvm-lit'
_test "opt available" 'command -v opt'
_test "llc available" 'command -v llc'
echo

# Test 4: Tool Functionality
_test_with_output "clang version" 'clang --version | head -1'
_test "clang compilation" 'echo "int main(){return 0;}" | clang -x c - -o /tmp/smoke_test && rm -f /tmp/smoke_test'
_test "FileCheck basic test" 'echo "Hello" | FileCheck <(echo "CHECK: Hello") --input-file=-'
_test "llvm-lit help" 'llvm-lit --help'
echo

# Test 5: FileCheck Example (if available)
if [ -d "ch1/FileCheckExamples/ex1" ]; then
  _test "FileCheck example ex1" 'cd ch1/FileCheckExamples/ex1 && bash run.sh && cd - >/dev/null'
else
  echo "${_test_count}. FileCheck example: SKIP (not found)"
fi
echo

# Test 6: Test Suite (if configured)
if [ -n "${LLVM_TEST_BUILD:-}" ] && [ -d "${LLVM_TEST_BUILD}" ]; then
  _test "Test suite build configured" '[ -f "${LLVM_TEST_BUILD}/build.ninja" ] || [ -f "${LLVM_TEST_BUILD}/Makefile" ]'
  if [ -n "${LIT:-}" ] && [ -f "${LLVM_TEST_BUILD}/lit.site.cfg" ]; then
    _test "Test suite lit config" '"${LIT}" --show-suites "${LLVM_TEST_BUILD}"'
    _test "Test suite quick run" '"${LIT}" --max-tests=1 "${LLVM_TEST_BUILD}"'
  fi
else
  echo "${_test_count}. Test suite: SKIP (not configured)"
fi
echo

# Test 7: CMake Integration (if available)
if [ -n "${CC:-}" ] && [ -n "${CXX:-}" ]; then
  _test "CC compiler works" '"${CC}" --version'
  _test "CXX compiler works" '"${CXX}" --version'
  if [ -n "${LLVM_DIR:-}" ]; then
    _test "LLVM CMake config exists" '[ -f "${LLVM_DIR}/LLVMConfig.cmake" ]'
  fi
fi
echo

# Summary
echo "=== Test Results ==="
echo "Passed: ${_pass_count}/${_test_count} tests"

if [ ${_pass_count} -eq ${_test_count} ]; then
  echo "🎉 All tests passed! Your LLVM environment is fully functional."
  exit 0
elif [ ${_pass_count} -gt $(((_test_count * 2) / 3)) ]; then
  echo "⚠️  Most tests passed. Environment is mostly functional."
  exit 0
else
  echo "❌ Many tests failed. Please check your LLVM installation."
  exit 1
fi