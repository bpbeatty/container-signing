[![build-ublue](https://github.com/bpbeatty/container-signing/actions/workflows/build.yml/badge.svg)](https://github.com/bpbeatty/container-signing/actions/workflows/build.yml)

# container-signing

A layer for adding a signed image config.

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/bpbeatty/container-signing
