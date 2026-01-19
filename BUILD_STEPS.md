# DELL_S2725HS Build Steps

Complete guide to build DELL_S2725HS Debian package and installation bundle.

---

## Prerequisites

Before building, ensure you have the following installed:

- **Docker** (with BuildKit support)
- **Git** (for version information)
- **Bash** (for build scripts)
- **Docker Buildx** (for multi-platform builds)

### Enable Multi-Architecture Docker Support (Optional)

For building for multiple architectures (ARM and AMD64):

```bash
./dev-scripts/enable-multiarch-docker
```

---

## Step 1: Build Debian Package

### Quick Build (Default Architectures)

Build for both ARM v7 and AMD64 architectures:

```bash
./dev-scripts/build-debian-pkg
```

### Build for Specific Architecture

Build for ARM v7 only (Raspberry Pi):

```bash
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'
```

Build for AMD64 only:

```bash
./dev-scripts/build-debian-pkg --build-targets 'linux/amd64'
```

### Build with Custom Version

Specify a custom version identifier:

```bash
./dev-scripts/build-debian-pkg --dells2725hs-version '2.5.0'
```

### Output

The Debian package will be created in:

```
debian-pkg/releases/dells2725hs-<VERSION>.deb
```

---

## Step 2: Create Installation Bundle

Move the built package to bundler and create installation bundle:

```bash
mv debian-pkg/releases/dells2725hs*.deb bundler/bundle/
./bundler/create-bundle
```

### Output

The installation bundle will be created in:

```
bundler/dist/dells2725hs-<VARIANT>-<TIMESTAMP>-<VERSION>.tgz
```

---

## Step 3: Verify Bundle Integrity (Optional)

Verify the bundle was created correctly:

```bash
./bundler/verify-bundle
```

---

## Complete Build & Bundle Process

Run everything in one command (ARM v7 architecture):

```bash
TARGET_PLATFORM='linux/arm/v7'

(rm debian-pkg/releases/dells2725hs*.deb || true) && \
  ./dev-scripts/build-debian-pkg --build-targets "${TARGET_PLATFORM}" && \
  mv debian-pkg/releases/dells2725hs*.deb bundler/bundle && \
  ./bundler/create-bundle
```

---

## Development & Testing

### Check Style & Lint

Run all code quality checks:

```bash
./dev-scripts/check-all
```

Individual checks:

```bash
./dev-scripts/check-python      # Python linting
./dev-scripts/check-bash        # Bash linting
./dev-scripts/check-javascript  # JavaScript linting
./dev-scripts/fix-style         # Auto-fix style issues
```

### Run Tests

```bash
python -m pytest app/
```

### Install from Source (Development)

Build and install on device from source code:

```bash
./dev-scripts/device/install-from-source
```

---

## File Structure After Build

```
debian-pkg/
  releases/
    dells2725hs-20240116T120000-2.5.0.deb  ← Debian package

bundler/
  bundle/
    dells2725hs-20240116T120000-2.5.0.deb  ← Copy of package
  dist/
    dells2725hs-community-20240116T1200Z-2.5.0.tgz  ← Installation bundle
```

---

## Build Options Summary

| Option | Purpose | Example |
|--------|---------|---------|
| `--build-targets` | Target architectures (comma-separated) | `--build-targets 'linux/arm/v7,linux/amd64'` |
| `--dells2725hs-version` | Custom version string | `--dells2725hs-version '2.5.0'` |
| `--help` | Show help message | `./dev-scripts/build-debian-pkg --help` |

---

## Troubleshooting

### Docker BuildKit Not Available

Enable Docker BuildKit:

```bash
export DOCKER_BUILDKIT=1
```

### Build Fails with Permission Issues

Check Docker permissions:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Multi-platform Build Not Supported

Install Docker Buildx:

```bash
docker buildx create --name builder
docker buildx use builder
docker buildx inspect --bootstrap
```

---

## Installation

After bundle creation, install on Raspberry Pi:

```bash
sudo bash bundler/dist/dells2725hs-*.tgz
```

Or use the provided installation script:

```bash
sudo ./dev-scripts/device/install-bundle /path/to/bundle.tgz
```

---

## Version Format

DELL_S2725HS uses semantic versioning with git hash:

- **Format**: `x.y.z-i+hhhhhhh`
  - `x.y.z` = Semantic version
  - `i` = Number of commits since last tag
  - `hhhhhhh` = Git commit hash (7+ characters)

**Example**: `2.5.0-16+7a6c812`

---

## Build Variables

Key environment variables used during build:

| Variable | Description |
|----------|-------------|
| `DELLS2725HS_VERSION` | Semantic version of release |
| `PKG_VERSION` | Debian package version (timestamp format) |
| `BUILD_TARGETS` | Docker platform targets |
| `DOCKER_BUILDKIT` | Enable Docker BuildKit (set to 1) |

---

## CI/CD Integration

For CI pipelines, the build script detects CI environment and adjusts Docker output:

```bash
export CI=true
./dev-scripts/build-debian-pkg
```

This will use plain Docker progress output instead of colored output.

---

## Summary Checklist

- [ ] Docker and Docker Buildx installed
- [ ] Multi-arch support enabled (if building for multiple platforms)
- [ ] Run `./dev-scripts/build-debian-pkg`
- [ ] Verify `.deb` file created in `debian-pkg/releases/`
- [ ] Move package to `bundler/bundle/`
- [ ] Run `./bundler/create-bundle`
- [ ] Verify bundle created in `bundler/dist/`
- [ ] Test bundle with `./bundler/verify-bundle`

---

**Last Updated**: January 16, 2026
**DELL_S2725HS Version**: 2.5.0+
