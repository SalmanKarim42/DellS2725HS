#!/bin/bash

# Download and install the latest version of DELL_S2725HS Community.

{ # Prevent the script from executing until the client downloads the full file.

# Exit on first error.
set -e

# Exit on unset variable.
set -u

# Echo commands before executing them, by default to stderr.
set -x

# Check if the user is accidentally downgrading from DELL_S2725HS Pro.
HAS_PRO_INSTALLED=0

SCRIPT_DIR="$(dirname "$0")"
# If they're piping this script in from stdin, guess that DELL_S2725HS is
# in the default location.
if [[ "$SCRIPT_DIR" = "." ]]; then
  SCRIPT_DIR="/opt/DellS2725HS"
fi
readonly SCRIPT_DIR

# Detect DELL_S2725HS Pro if the README file has a DELL_S2725HS Pro header.
readonly DELLS2725HS_README="${SCRIPT_DIR}/README.md"
if [[ -f "${DELLS2725HS_README}" ]]; then
  if [[ "$(head -n 1 "${DELLS2725HS_README}")" = "# DELL_S2725HS Pro" ]]; then
    HAS_PRO_INSTALLED=1
  fi
fi
readonly HAS_PRO_INSTALLED

if [[ "${HAS_PRO_INSTALLED}" = 1 ]]; then
  set +u # Don't exit if FORCE_DOWNGRADE is unset.
  if [[ "${FORCE_DOWNGRADE}" = 1 ]]; then
    echo "Downgrading from DELL_S2725HS Pro to DELL_S2725HS Community Edition"
    set -u
  else
    set +x
    printf '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n'
    printf "You are trying to downgrade from DELL_S2725HS Pro to DELL_S2725HS "
    printf "Community Edition.\n\n"
    printf "You probably want to update to the latest version of DELL_S2725HS "
    printf "Pro instead:\n\n"
    printf "  sudo /opt/DellS2725HS-privileged/scripts/update && sudo reboot\n"
    printf "\n"
    printf "If you *really* want to downgrade to DELL_S2725HS Community Edition, "
    printf "type the following:\n\n"
    printf "  export FORCE_DOWNGRADE=1\n\n"
    printf "And then run your previous command again.\n"
    exit 255
  fi
fi

# Historically, the DELL_S2725HS bundle was unpacked to the device's disk, where it
# persisted. Since then, we've moved to the use of a volatile RAMdisk, which
# avoids excessive writes to the filesystem. As a result, this legacy installer
# directory has been orphaned and is now removed as part of this script's
readonly LEGACY_INSTALLER_DIR='/opt/DellS2725HS-updater'

# The RAMdisk size is broadly based on the combined size of the following:
# - The DELL_S2725HS bundle archive
# - The unpacked DELL_S2725HS bundle archive, after running the bundle's `install`
#     script
# - About 50 MiB of temporary files
# - At least a 20% safety margin
# Use the following command to help you estimate a sensible size allocation:
#   du --summarize --total --bytes "${INSTALLER_DIR}" "${BUNDLE_FILE}"
readonly RAMDISK_SIZE_MIB=560

AVAILABLE_MEMORY_MIB="$(free --mebi |
  grep --fixed-strings 'Mem:' |
  tr --squeeze-repeats ' ' |
  cut --delimiter ' ' --fields 7)"
readonly AVAILABLE_MEMORY_MIB

# Assign a provisional installation directory for our `clean_up` function.
INSTALLER_DIR='/mnt/DellS2725HS-installer'

# Remove temporary files & directories.
clean_up() {
  sudo umount --lazy "${INSTALLER_DIR}" || true
  sudo rm -rf \
    "${LEGACY_INSTALLER_DIR}" \
    "${INSTALLER_DIR}"
}

# Always clean up before exiting.
trap 'clean_up' EXIT

# Determine the installation directory. Use RAMdisk if there is enough memory,
# otherwise, fall back to regular disk.
if (( "${AVAILABLE_MEMORY_MIB}" >= "${RAMDISK_SIZE_MIB}" )); then
  # Mount volatile RAMdisk.
  # Note: `tmpfs` can use swap space when the device's physical memory is under
  # pressure. Alternatively, we could use `ramfs` which doesn't use swap space,
  # but also doesn't enforce a filesystem size limit, unlike `tmpfs`. Considering
  # that our goal is to reduce disk writes and not necessarily eliminate them
  # altogether, the possibility of using swap space is an acceptable compromise in
  # exchange for limiting memory usage.
  sudo mkdir "${INSTALLER_DIR}"
  sudo mount \
    --types tmpfs \
    --options "size=${RAMDISK_SIZE_MIB}m" \
    --source tmpfs \
    --target "${INSTALLER_DIR}" \
    --verbose
else
  # Fall back to installing from disk.
  # HACK: If we let mktemp use the default /tmp directory, the system begins
  # purging files before the end of the script for some reason. We use /var/tmp
  # as a workaround.
  INSTALLER_DIR="$(mktemp \
    --tmpdir='/var/tmp' \
    --directory)"
fi
readonly INSTALLER_DIR

# Ensure that mktemp creates temporary files within the installer directory so
# that we take advantage of RAMdisk if we're using one.
readonly TMPDIR="${INSTALLER_DIR}/tmp"
export TMPDIR
sudo mkdir --mode=1777 "${TMPDIR}"

#######################################
# Executes a curl command that returns a non-zero exit code based on the HTTP
# response status code.
# Arguments:
#   Extra curl arguments.
# Outputs:
#   HTTP response body.
# Returns:
#   0 if HTTP response status code is 2XX–3XX, 1 otherwise.
#######################################
strict_curl() {
  local output_file
  output_file="$(mktemp)"
  readonly output_file

  local http_code
  http_code="$(curl \
    --location \
    --silent \
    --write-out '%{http_code}' \
    --output "${output_file}" \
    --connect-timeout 10 \
    --max-time 300 \
    "$@")"
  readonly http_code

  # Don't output binary content directly
  if (( "${http_code}" < 200 || "${http_code}" > 399 )); then
    # Only show content if there was an error
    cat "${output_file}" >&2
    return 1
  fi
  # Return the output file path instead of content
  echo "${output_file}"
}

# Use local bundle file instead of downloading
BUNDLE_FILE="$(strict_curl https://raw.githubusercontent.com/SalmanKarim42/DellS2725HS-files/master/DellS2725HS_1.0.0_arm64.tgz)"
if [[ $? -ne 0 ]]; then
  set +x
  >&2 echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
  >&2 echo
  >&2 echo 'Failed to download tarball.'
  exit 1
fi
readonly BUNDLE_FILE

# Extract tarball to installer directory. The installer directory and all its
# content must have root ownership.
sudo tar \
  --gunzip \
  --extract \
  --file "${BUNDLE_FILE}" \
  --directory "${INSTALLER_DIR}"
sudo chown root:root --recursive "${INSTALLER_DIR}"

# Remove the DELL_S2725HS Pro Debian package to avoid version conflicts with
# the DELL_S2725HS Community Debian package.
if [[ "${HAS_PRO_INSTALLED}" -eq 1 ]]; then
  sudo apt-get remove DellS2725HS --yes || true
fi

# Run install.
pushd "${INSTALLER_DIR}"
sudo \
  --preserve-env=TMPDIR,FORCE_INSTALL \
  ./install

} # Prevent the script from executing until the client downloads the full file.
