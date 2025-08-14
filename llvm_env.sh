#!/usr/bin/env bash

# LLVM Development Environment Setup
# Usage: source ./llvm_env.sh
#
# This script exports environment variables for LLVM development.
# Variables are only set if the corresponding paths actually exist.

set -euo pipefail

# Resolve repo root (directory containing this script)
_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="${REPO_ROOT:-${_SCRIPT_DIR}}"

# Helper function to find first existing directory
_find_existing_dir() {
  for _path in "$@"; do
    if [ -d "${_path}" ]; then
      echo "${_path}"
      return 0
    fi
  done
  return 1
}

# Helper function to find first existing file
_find_existing_file() {
  for _path in "$@"; do
    if [ -f "${_path}" ]; then
      echo "${_path}"
      return 0
    fi
  done
  return 1
}

# --- LLVM Source Directories ---
if [ -z "${LLVM_SRC:-}" ]; then
  if LLVM_SRC=$(_find_existing_dir \
    "${REPO_ROOT}/source/llvm-project" \
    "${REPO_ROOT}/llvm-project" \
    "${REPO_ROOT}/../llvm-project" 2>/dev/null); then
    export LLVM_SRC
  fi
fi

# LLVM subproject directory
if [ -z "${LLVM_SRC_LLVM:-}" ] && [ -n "${LLVM_SRC:-}" ] && [ -d "${LLVM_SRC}/llvm" ]; then
  export LLVM_SRC_LLVM="${LLVM_SRC}/llvm"
fi

# --- LLVM Build/Install Directories ---
if [ -z "${LLVM_BIN:-}" ]; then
  if LLVM_BIN=$(_find_existing_dir \
    "${REPO_ROOT}/source/clang/bin" \
    "${REPO_ROOT}/source/bin" \
    "${REPO_ROOT}/build/bin" \
    "${REPO_ROOT}/../build/bin" 2>/dev/null); then
    export LLVM_BIN
  elif command -v llc >/dev/null 2>&1; then
    # Fallback to PATH
    LLVM_BIN="$(dirname "$(command -v llc)")"
    export LLVM_BIN
  fi
fi

if [ -z "${LLVM_BUILD:-}" ]; then
  if LLVM_BUILD=$(_find_existing_dir \
    "${REPO_ROOT}/source/build" \
    "${REPO_ROOT}/build" \
    "${REPO_ROOT}/../build" 2>/dev/null); then
    export LLVM_BUILD
  fi
fi

# --- LLVM CMake Directory ---
if [ -z "${LLVM_DIR:-}" ] && [ -n "${LLVM_BIN:-}" ]; then
  if [ -x "${LLVM_BIN}/llvm-config" ]; then
    if _cmake_dir="$(${LLVM_BIN}/llvm-config --cmakedir 2>/dev/null)" && [ -d "${_cmake_dir}" ]; then
      export LLVM_DIR="${_cmake_dir}"
    fi
  else
    # Try common locations relative to LLVM_BIN
    if LLVM_DIR=$(_find_existing_dir \
      "${LLVM_BIN}/../lib/cmake/llvm" \
      "${REPO_ROOT}/source/clang/lib/cmake/llvm" 2>/dev/null); then
      export LLVM_DIR
    fi
  fi
fi

# --- Test Suite Directories ---
if [ -z "${LLVM_TEST_SUITE_SRC:-}" ]; then
  if LLVM_TEST_SUITE_SRC=$(_find_existing_dir \
    "${REPO_ROOT}/source/llvm-test-suite" \
    "${REPO_ROOT}/llvm-test-suite" \
    "${REPO_ROOT}/../llvm-test-suite" 2>/dev/null); then
    export LLVM_TEST_SUITE_SRC
  fi
fi

if [ -z "${LLVM_TEST_BUILD:-}" ]; then
  if LLVM_TEST_BUILD=$(_find_existing_dir \
    "${REPO_ROOT}/source/llvm-test-suite/build" \
    "${REPO_ROOT}/llvm-test-suite/build" \
    "${REPO_ROOT}/llvm-test-build" 2>/dev/null); then
    export LLVM_TEST_BUILD
  elif [ -n "${LLVM_TEST_SUITE_SRC:-}" ]; then
    # Default location if source exists but build doesn't
    export LLVM_TEST_BUILD="${LLVM_TEST_SUITE_SRC}/build"
  fi
fi

# --- Individual Tools (only if they exist) ---
if [ -n "${LLVM_BIN:-}" ]; then
  [ -x "${LLVM_BIN}/llvm-lit" ] && export LIT="${LLVM_BIN}/llvm-lit"
  [ -x "${LLVM_BIN}/FileCheck" ] && export FILECHECK="${LLVM_BIN}/FileCheck"
  [ -x "${LLVM_BIN}/clang" ] && export CLANG="${LLVM_BIN}/clang"
  [ -x "${LLVM_BIN}/clang++" ] && export CXX="${LLVM_BIN}/clang++"
  [ -x "${LLVM_BIN}/opt" ] && export OPT="${LLVM_BIN}/opt"
  [ -x "${LLVM_BIN}/llc" ] && export LLC="${LLVM_BIN}/llc"
  
  # Compiler variables for CMake
  [ -x "${LLVM_BIN}/clang" ] && export CC="${LLVM_BIN}/clang"
  [ -x "${LLVM_BIN}/clang" ] && export ASM="${LLVM_BIN}/clang"
fi

# --- Environment Setup ---
# Add LLVM_BIN to PATH if not already there
if [ -n "${LLVM_BIN:-}" ] && [[ ":${PATH}:" != *":${LLVM_BIN}:"* ]]; then
  export PATH="${LLVM_BIN}:${PATH}"
fi

# Set lit options
export LIT_OPTS="${LIT_OPTS:--sv -j$(nproc 2>/dev/null || echo 4)}"

# Add lib directory to LD_LIBRARY_PATH if it exists
if [ -n "${LLVM_BIN:-}" ] && [ -d "${LLVM_BIN}/../lib" ]; then
  _lib_dir="${LLVM_BIN}/../lib"
  if [ -z "${LD_LIBRARY_PATH:-}" ]; then
    export LD_LIBRARY_PATH="${_lib_dir}"
  elif [[ ":${LD_LIBRARY_PATH}:" != *":${_lib_dir}:"* ]]; then
    export LD_LIBRARY_PATH="${_lib_dir}:${LD_LIBRARY_PATH}"
  fi
fi

# --- Summary ---
echo "[llvm_env] LLVM Development Environment Loaded"
echo "[llvm_env] REPO_ROOT=${REPO_ROOT}"

# Only show variables that are actually set
[ -n "${LLVM_SRC:-}" ] && echo "[llvm_env] LLVM_SRC=${LLVM_SRC}"
[ -n "${LLVM_SRC_LLVM:-}" ] && echo "[llvm_env] LLVM_SRC_LLVM=${LLVM_SRC_LLVM}"
[ -n "${LLVM_BUILD:-}" ] && echo "[llvm_env] LLVM_BUILD=${LLVM_BUILD}"
[ -n "${LLVM_BIN:-}" ] && echo "[llvm_env] LLVM_BIN=${LLVM_BIN}"
[ -n "${LLVM_DIR:-}" ] && echo "[llvm_env] LLVM_DIR=${LLVM_DIR}"
[ -n "${LLVM_TEST_SUITE_SRC:-}" ] && echo "[llvm_env] LLVM_TEST_SUITE_SRC=${LLVM_TEST_SUITE_SRC}"
[ -n "${LLVM_TEST_BUILD:-}" ] && echo "[llvm_env] LLVM_TEST_BUILD=${LLVM_TEST_BUILD}"

# Show available tools
_tools_found=()
[ -n "${LIT:-}" ] && _tools_found+=("llvm-lit")
[ -n "${FILECHECK:-}" ] && _tools_found+=("FileCheck")
[ -n "${CLANG:-}" ] && _tools_found+=("clang")
[ -n "${OPT:-}" ] && _tools_found+=("opt")
[ -n "${LLC:-}" ] && _tools_found+=("llc")

if [ ${#_tools_found[@]} -gt 0 ]; then
  echo "[llvm_env] Tools available: ${_tools_found[*]}"
fi

echo "[llvm_env] Environment ready!"