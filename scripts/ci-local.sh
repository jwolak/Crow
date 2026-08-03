#!/usr/bin/env bash
set -euo pipefail

print_usage() {
    cat <<'EOF'
Usage: scripts/ci-local.sh [options]

Build Crow in two CI-like configurations:
  1) Boost.Asio   (CROW_USE_BOOST=ON)
  2) standalone Asio (CROW_USE_BOOST=OFF)

Options:
  --build-type <type>   CMake build type (default: Release)
  --jobs <n>            Parallel build jobs (default: nproc or 4)
  --target <name>       Build target (default: all)
  --examples <ON|OFF>   Build examples (default: ON)
  --tests <ON|OFF>      Build tests (default: ON)
  --clean               Remove build directories before configure
  --help                Show this help and exit

Examples:
  scripts/ci-local.sh
  scripts/ci-local.sh --target unittest --jobs 8
  scripts/ci-local.sh --clean --examples OFF --tests ON
EOF
}

BUILD_TYPE="Release"
TARGET=""
BUILD_EXAMPLES="ON"
BUILD_TESTS="ON"
CLEAN="OFF"

if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
else
    JOBS="4"
fi

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build-type)
            BUILD_TYPE="${2:-}"
            shift 2
            ;;
        --jobs)
            JOBS="${2:-}"
            shift 2
            ;;
        --target)
            TARGET="${2:-}"
            shift 2
            ;;
        --examples)
            BUILD_EXAMPLES="${2:-}"
            shift 2
            ;;
        --tests)
            BUILD_TESTS="${2:-}"
            shift 2
            ;;
        --clean)
            CLEAN="ON"
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            print_usage >&2
            exit 1
            ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BOOST_BUILD_DIR="$ROOT_DIR/build_ci_boost"
ASIO_BUILD_DIR="$ROOT_DIR/build_ci_asio"

configure_and_build() {
    local build_dir="$1"
    local use_boost="$2"
    local label="$3"

    echo "==> [$label] configure"
    cmake -S "$ROOT_DIR" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCROW_USE_BOOST="$use_boost" \
        -DCROW_BUILD_TESTS="$BUILD_TESTS" \
        -DCROW_BUILD_EXAMPLES="$BUILD_EXAMPLES"

    echo "==> [$label] build"
    if [[ -n "$TARGET" ]]; then
        cmake --build "$build_dir" --config "$BUILD_TYPE" --target "$TARGET" -j"$JOBS"
    else
        cmake --build "$build_dir" --config "$BUILD_TYPE" -j"$JOBS"
    fi
}

if [[ "$CLEAN" == "ON" ]]; then
    echo "==> Cleaning build directories"
    rm -rf "$BOOST_BUILD_DIR" "$ASIO_BUILD_DIR"
fi

configure_and_build "$BOOST_BUILD_DIR" "ON" "Boost"
configure_and_build "$ASIO_BUILD_DIR" "OFF" "Asio"

echo "==> Done. Both local CI-like builds succeeded."
