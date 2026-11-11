#!/bin/bash
# Signs defs/ into site/ with the official offline key, for the maintainer
# only. Then review `git diff site/`, commit and push; Pages publishes it.
#
#   scripts/sign.sh /media/offline/cirrusstore.key [DAYS]
#
# An unchanged definition keeps its serial and only gets a new expiry
# (DAYS, default 180); a changed one goes up by one. An app removed from
# defs/ leaves the catalogue. The index's serial goes up on every run.
set -euo pipefail
key=${1:?usage: scripts/sign.sh /path/to/cirrusstore.key [DAYS]}
days=${2:-180}
key=$(cd "$(dirname "$key")" && pwd)/$(basename "$key")
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

# Broken definitions are refused before anything is signed. The old site
# isn't checked: an expired one is exactly what this run replaces.
scripts/check.sh --defs-only >/dev/null
tool=$(scripts/tool.sh)

shopt -s nullglob
for f in site/apps/*.json; do
	id=$(basename "$f" .json)
	if [ ! -f "defs/$id.json" ]; then
		rm -f "site/apps/$id.json" "site/apps/$id.json.sig"
		echo "removed: $id"
	fi
done
"$tool" sign -key "$key" -source cirrusstore -days "$days" -dir site defs/*.json
"$tool" index -key "$key" -source cirrusstore -days "$days" -dir site
if ! "$tool" verify -pub cirrusstore.pub site; then
	echo "sign.sh: site/ doesn't verify against cirrusstore.pub: is this the official key?" >&2
	echo "sign.sh: undo with: git checkout -- site/ && git clean -fd site/" >&2
	exit 1
fi
rm -f site/.gitkeep
echo
git status --short site
