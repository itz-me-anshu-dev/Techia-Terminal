#!/bin/sh
# One-command Techia VPS installer for Linux (per-user, no sudo needed).
#
# Installs techia-vps into ~/.local/bin after SHA-256 verification.
# Nothing executes unverified.
#
# USAGE (normal users copy-paste one line):
#   curl -fsSL https://github.com/anshu20120000-pixel/techia-app/releases/download/v1.0.0/install-vps.sh | sh
#
# Replace OWNER/REPO with the real release when publishing. Parameters below
# allow installing from any base (including a local test dir over http).
#
# Needs: curl, sha256sum (present on virtually every Linux).
set -eu
RELEASE_BASE="${RELEASE_BASE:-https://github.com/anshu20120000-pixel/techia-app/releases/download/v1.0.0}"
ARCH="${ARCH:-linux-x64}"
FILE_NAME="techia-vps-${ARCH}"

case "$RELEASE_BASE" in
  *OWNER/REPO*)
    echo "Techia VPS installer: no release URL configured."
    echo "Publish a release first, then run:"
    echo "  curl -fsSL <release-url>/install-vps.sh | sh"
    exit 2
    ;;
esac

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/techia-vps-install-XXXXXXXX")"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT INT TERM

echo "[1/3] Downloading $FILE_NAME ..."
curl -fsSL --max-time 300 -o "$TMP_DIR/$FILE_NAME" "$RELEASE_BASE/$FILE_NAME"
curl -fsSL --max-time 60 -o "$TMP_DIR/SHA256SUMS" "$RELEASE_BASE/SHA256SUMS"

echo "[2/3] Verifying checksum ..."
cd "$TMP_DIR"
want="$(awk -v f="$FILE_NAME" '$2 == f { print $1 }' SHA256SUMS)"
got="$(sha256sum "$FILE_NAME" | awk '{ print $1 }')"
if [ -z "$want" ]; then
  echo "SHA256SUMS has no entry for $FILE_NAME - refusing to install."
  exit 1
fi
if [ "$want" != "$got" ]; then
  echo "Checksum mismatch for $FILE_NAME - refusing to install."
  exit 1
fi
echo "        checksum ok."

echo "[3/3] Installing to ~/.local/bin (per-user, no sudo) ..."
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
cp "$TMP_DIR/$FILE_NAME" "$BIN_DIR/techia-vps"
chmod +x "$BIN_DIR/techia-vps"

echo ""
echo "Done. If ~/.local/bin is not on your PATH, add this line to ~/.bashrc:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo "Then verify with:  techia-vps --version"

