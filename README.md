TARGET_PLATFORM='linux/arm/v7'

(rm debian-pkg/releases/dells2725hs*.deb || true) && \
  ./dev-scripts/build-debian-pkg --build-targets "${TARGET_PLATFORM}" && \
  mv debian-pkg/releases/dells2725hs*.deb bundler/bundle && \
  ./bundler/create-bundle

1. after script open bunlder/bundle folder and copy file to DellS2725HS-files folders.
2. and push to its repo 