# Local CI Build Script

This folder contains [ci-local.sh](ci-local.sh), a helper script for running two CI-like local builds of Crow.

It configures and builds:

1. Boost.Asio variant (`CROW_USE_BOOST=ON`) in `build_ci_boost`
2. standalone Asio variant (`CROW_USE_BOOST=OFF`) in `build_ci_asio`

The goal is to catch configuration-specific build issues (for example Boost-only or Asio-only errors) before pushing.

## Quick start

From repository root:

```bash
./scripts/ci-local.sh
```

## Common usage

Build only `unittest` target:

```bash
./scripts/ci-local.sh --target unittest
```

Clean both build directories first:

```bash
./scripts/ci-local.sh --clean
```

Use custom parallelism and build type:

```bash
./scripts/ci-local.sh --jobs 8 --build-type Release
```

Disable examples for faster checks:

```bash
./scripts/ci-local.sh --examples OFF --tests ON
```

## Options

```text
--build-type <type>   CMake build type (default: Release)
--jobs <n>            Parallel build jobs (default: nproc or 4)
--target <name>       Build target (default: all)
--examples <ON|OFF>   Build examples (default: ON)
--tests <ON|OFF>      Build tests (default: ON)
--clean               Remove build directories before configure
--help                Show help
```

## Notes

- The script is safe to keep in your fork and run locally.
- It does not modify source files.
- It creates/updates `build_ci_boost` and `build_ci_asio` directories.
