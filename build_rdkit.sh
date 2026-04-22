#!/usr/bin/env bash
set -euo pipefail

RDKIT_SRC="$(pwd)/vendor/rdkit"
RDKIT_BUILD="$(pwd)/build/rdkit"
RDKIT_INSTALL="$(pwd)/install/rdkit"

mkdir -p "$RDKIT_BUILD"

cmake -S "$RDKIT_SRC" -B "$RDKIT_BUILD" \
  -DRDK_BUILD_CFFI_LIB=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=OFF \
  -DRDK_BUILD_PYCAIRO=OFF \
  -DRDK_BUILD_TESTS=OFF \
  -DRDK_BUILD_DOCS=OFF \
  -DRDK_BUILD_CPP_TESTS=OFF \
  -DRDK_INSTALL_STATIC_LIBS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$RDKIT_INSTALL"

cmake --build "$RDKIT_BUILD" -- -j"$(nproc)"
cmake --install "$RDKIT_BUILD"

echo "--------------------------------------"
echo "RDKit built and installed to $RDKIT_INSTALL"
echo "librdkitcffi.so:"
find "$RDKIT_INSTALL" -name "librdkitcffi*"
echo "--------------------------------------"
