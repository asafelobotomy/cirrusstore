#!/bin/bash
# Builds the cirrusstore publisher tool from the CirrusUX release pinned in
# cirrusux.env, and prints its path. Needs git and Go.
#
# CIRRUSUX_SRC=/path/to/CirrusUX builds from that checkout instead, with no
# commit check: for trying a change to the tool before it is released.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091 # two KEY=value lines
. "$root/cirrusux.env"

build() { # build SRC OUT VERSION
	(cd "$1" && CGO_ENABLED=0 go build -trimpath \
		-ldflags "-s -w -X cirrusux/internal/version.Version=$3" \
		-o "$2" ./cmd/cirrusstore)
}

mkdir -p "$root/.tools"
if [ -n "${CIRRUSUX_SRC:-}" ]; then
	out="$root/.tools/cirrusstore-local"
	build "$CIRRUSUX_SRC" "$out" "$(cat "$CIRRUSUX_SRC/VERSION")" >&2
	echo "$out"
	exit 0
fi

out="$root/.tools/cirrusstore-$CIRRUSUX_TAG"
if [ ! -x "$out" ]; then
	src=$(mktemp -d)
	trap 'rm -rf "$src"' EXIT
	url=https://github.com/asafelobotomy/CirrusUX.git
	tagged=$(git ls-remote "$url" "refs/tags/$CIRRUSUX_TAG^{}" | cut -f1)
	if [ "$tagged" != "$CIRRUSUX_COMMIT" ]; then
		echo "tool.sh: $CIRRUSUX_TAG is commit ${tagged:-missing}, but cirrusux.env pins $CIRRUSUX_COMMIT" >&2
		exit 1
	fi
	git -C "$src" init -q
	git -C "$src" fetch -q --depth 1 "$url" "$CIRRUSUX_COMMIT"
	git -C "$src" -c advice.detachedHead=false checkout -q FETCH_HEAD
	build "$src" "$out" "${CIRRUSUX_TAG#v}" >&2
fi
echo "$out"
