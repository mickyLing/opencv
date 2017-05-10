#!/usr/bin/env sh
set -e

if [ -z "$NDK_ROOT" ] && [ "$#" -eq 0 ]; then
    echo 'Either $NDK_ROOT should be set or provided as argument'
    echo "e.g., 'export NDK_ROOT=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    NDK_ROOT="${1:-${NDK_ROOT}}"
fi

ANDROID_ABI=${ANDROID_ABI:-"armeabi-v7a with NEON"}
WD=$(readlink -f "`dirname $0`/.")
BUILD_DIR=${WD}/build_android
INSTALL_DIR=${WD}/android_lib
N_JOBS=${N_JOBS:-16}

API_LEVEL=19

if [ ! -d "${BUILD_DIR}" ]; then
  mkdir -p "${BUILD_DIR}"
fi

cd "${BUILD_DIR}"

cmake -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
      -DCMAKE_TOOLCHAIN_FILE="${WD}/platforms/android/android.toolchain.cmake" \
      -DANDROID_NDK="${NDK_ROOT}" \
      -DANDROID_NATIVE_API_LEVEL=${API_LEVEL} \
      -DANDROID_ABI="${ANDROID_ABI}" \
      -D WITH_CUDA=OFF \
      -D WITH_MATLAB=OFF \
      -D BUILD_ANDROID_EXAMPLES=OFF \
      -D BUILD_DOCS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D BUILD_TESTS=OFF \
      -D HAVE_OPENMP=ON \
      -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}/opencv" \
      ..

make -j${N_JOBS}
make install/strip

cd "${WD}"
