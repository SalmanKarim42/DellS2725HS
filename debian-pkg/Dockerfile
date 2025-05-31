# syntax=docker/dockerfile:1.4
# Enable here-documents:
# https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md#here-documents

FROM debian:bullseye-20220328-slim AS build

RUN set -exu && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      debhelper \
      dh-virtualenv \
      dpkg-dev

# Docker populates this value from the --platform argument. See
# https://docs.docker.com/build/building/multi-platform/
ARG TARGETPLATFORM

# The canonical, SemVer-compliant DELL_S2725HS version.
ARG DELLS2725HS_VERSION

# The `PKG_VERSION` is the version of the Debian package. Debian uses its own
# versioning scheme, which is not strictly compatible with DELL_S2725HS’s version
# conventions. Therefore, the package version should be a timestamp, formatted
# `YYYYMMDDhhmmss`. That way the package manager always installs the most
# recently built DELL_S2725HS package.
ARG PKG_VERSION

ARG PKG_NAME='DellS2725HS'
ARG PKG_BUILD_NUMBER='1'

# Docker's platform names don't match Debian's platform names, so we translate
# the platform name from the Docker version to the Debian version and save the
# result to a file so we can re-use it in later stages.
RUN cat | bash <<'EOF'
set -exu
case "${TARGETPLATFORM}" in
  'linux/amd64')
    PKG_ARCH='amd64'
    ;;
  'linux/arm/v7')
    PKG_ARCH='armhf'
    ;;
  *)
    echo "Unrecognized target platform: ${TARGETPLATFORM}" >&2
    exit 1
esac
echo "${PKG_ARCH}" > /tmp/pkg-arch
echo "${PKG_NAME}-${PKG_VERSION}-${PKG_BUILD_NUMBER}-${PKG_ARCH}" > /tmp/pkg-id
EOF

# We ultimately need the directory name to be the package ID, but there's no
# way to specify a dynamic value in Docker's WORKDIR command, so we use a
# placeholder directory name to assemble the Debian package and then rename the
# directory to its package ID name in the final stages of packaging.
WORKDIR /releases/placeholder-pkg-id

COPY ./debian-pkg ./
COPY ./COPYRIGHT ./
COPY ./LICENSE ./
COPY ./README.md ./
COPY ./requirements.txt ./
COPY ./app ./app
COPY ./scripts ./scripts

RUN echo "${DELLS2725HS_VERSION}" > VERSION

WORKDIR /releases/placeholder-pkg-id/debian

RUN set -exu && \
    PKG_ARCH="$(cat /tmp/pkg-arch)" && \
    cat >control <<EOF
Source: ${PKG_NAME}
Section: net
Priority: optional
Maintainer: DELL_S2725HS Support <support@DELL_S2725HS.com>
Build-Depends: debhelper (>= 11)

Package: ${PKG_NAME}
Architecture: ${PKG_ARCH}
Depends: \${shlibs:Depends}, adduser, janus, nginx, python3, python3-pip, python3-venv, sudo, ustreamer
Homepage: https://tinypilotkvm.com
Description: Simple, easy-to-use KVM over IP
XBS-Dell-S2725HS-Version: ${DELLS2725HS_VERSION}
EOF

RUN set -exu && \
    cat >changelog <<EOF
DellS2725HS (${PKG_VERSION}) bullseye; urgency=medium

  * Latest DELL_S2725HS release.

 -- DELL_S2725HS Support <support@DELL_S2725HS.com>  $(date '+%a, %d %b %Y %H:%M:%S %z')
EOF

# Rename the placeholder release directory to the final package ID.
WORKDIR /releases
RUN cat | bash <<'EOF'
set -exu
PKG_ID="$(cat /tmp/pkg-id)"
mv placeholder-pkg-id "${PKG_ID}"
cd "${PKG_ID}"
dpkg-buildpackage --build=binary
EOF

FROM scratch as artifact

COPY --from=build /releases/*.deb ./
