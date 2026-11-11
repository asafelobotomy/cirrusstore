#!/bin/bash
# Checks the repository without the signing key, the way CI does:
#   1. every definition in defs/ is one CirrusUX accepts (signed and
#      verified with a throwaway key), and its file is named after its id;
#   2. the published site/, once there is one, verifies against
#      cirrusstore.pub and doesn't expire within MIN_DAYS (default 30).
# Definitions that changed since the last signing are listed, not refused:
# a pull request adds them, and the maintainer signs later.
#
#   scripts/check.sh [--defs-only]
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
tool=$(scripts/tool.sh)
fail() { echo "check: $*" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# 1. Definitions
shopt -s nullglob
defs=(defs/*.json)
[ ${#defs[@]} -gt 0 ] || fail "defs/ has no definitions"
"$tool" keygen -name cirrusstore -out "$tmp" >/dev/null
"$tool" sign -key "$tmp/cirrusstore.key" -dir "$tmp/site" "${defs[@]}" >/dev/null
"$tool" index -key "$tmp/cirrusstore.key" -dir "$tmp/site" >/dev/null
"$tool" verify -pub "$tmp/cirrusstore.pub" "$tmp/site" >/dev/null
for f in "${defs[@]}"; do
	id=$(basename "$f" .json)
	[ -f "$tmp/site/apps/$id.json" ] || fail "$f: the file must be named after its id"
done
signed=("$tmp"/site/apps/*.json)
[ ${#signed[@]} -eq ${#defs[@]} ] || fail "two definitions share an id"
echo "definitions: ${#defs[@]} OK"
[ "${1:-}" != --defs-only ] || exit 0

# 2. The published site
if [ ! -f site/index.json ]; then
	echo "site: not signed yet (scripts/sign.sh, with the offline key)"
	exit 0
fi
"$tool" verify -pub cirrusstore.pub site >/dev/null || fail "site/ doesn't verify against cirrusstore.pub"
echo "site: verifies against cirrusstore.pub"

first=$(grep -h -m1 '"expires"' site/index.json site/apps/*.json | cut -d'"' -f4 | sort | head -1)
days=$(( ($(date -d "$first" +%s) - $(date +%s)) / 86400 ))
[ "$days" -ge "${MIN_DAYS:-30}" ] || fail "site/ expires in $days days ($first): re-sign it with scripts/sign.sh"
echo "site: first expiry $first, in $days days"

# What the next signing would change, as a note.
for f in "${defs[@]}"; do
	id=$(basename "$f" .json)
	[ -f "site/apps/$id.json" ] || { echo "pending: $id is new"; continue; }
	# The throwaway copy has serial 1; compare the app part only.
	a=$(sed -n '/"app"/,$p' "$tmp/site/apps/$id.json")
	b=$(sed -n '/"app"/,$p' "site/apps/$id.json")
	[ "$a" = "$b" ] || echo "pending: $id changed"
done
for f in site/apps/*.json; do
	id=$(basename "$f" .json)
	[ -f "defs/$id.json" ] || echo "pending: $id was removed from defs/"
done
