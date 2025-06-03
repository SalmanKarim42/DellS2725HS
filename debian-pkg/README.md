TARGET_PLATFORM='linux/arm/v7'7'

(rm debian-pkg/releases/dells2725hs*.deb || true) && \
  ./dev-scripts/build-debian-pkg --build-targets "${TARGET_PLATFORM}" && \
  mv debian-pkg/releases/dells2725hs*.deb bundler/bundle && \
  ./bundler/create-bundle