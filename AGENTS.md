# CirrusStore

The official, signed app catalogue for CirrusUX (sister repository:
`asafelobotomy/CirrusUX`, usually checked out beside this one as
`../CirrusUX`). Static files only, served by GitHub Pages at
`https://asafelobotomy.github.io/cirrusstore/`. README.md explains the
layout.

## Commands
- Check everything CI checks: `scripts/check.sh` (needs git and Go; it
  builds the pinned `cirrusstore` tool into `.tools/` the first time).
  `shellcheck scripts/*.sh` too.
- Try a tool change from a local CirrusUX checkout:
  `CIRRUSUX_SRC=../CirrusUX scripts/check.sh`.
- `scripts/sign.sh KEY` signs with the offline key. Only the maintainer
  runs it; never run it, never ask for the key, and never edit `site/` by
  hand: its files are signed byte for byte.

## Rules
- A change to the catalogue is a change to `defs/` only. One app per
  file, named `<id>.json`.
- Images are pinned by tag and `sha256` digest (of the tag's manifest, the
  image index for multi-arch images), never `latest`, betas or release
  candidates. Find a digest with
  `skopeo inspect --raw docker://IMAGE:TAG | sha256sum`.
- Set `minVersion` only when a definition uses a field newer than some
  CirrusUX release, and keep `cirrusux.env` at or above the newest
  `minVersion` (raise `CIRRUSUX_TAG` and `CIRRUSUX_COMMIT` together).
- Download apps (the Downloads group) share one writable media volume,
  `data` at `/data`: downloads in `/data/downloads`, the library in
  `/data/media/{films,series,music}`, so finished files move without a copy.
  New ones follow the same layout.
- No host port may clash with another app's: check every file in `defs/`.
- No secrets and no personal details: use `homeserver`, `192.0.2.x`,
  `aa:bb:cc:dd:ee:ff`.
- Plain English in descriptions and notes: short sentences, no jargon a
  home user wouldn't know.
- Pin GitHub Actions to commits, with the version in a comment.

## Open work
The first site was published on 11 November 2026 (serial 1, 19 apps,
expires 10 May 2027): signed by the maintainer, deployed by `pages.yml`,
verified from a download against `cirrusstore.pub`, and fetched by a
CirrusUX 0.7.1 panel, which installed, opened and removed Prowlarr from it.
Every app was first installed, opened and removed through a panel on a
Debian 13 test VM (Podman), and Sonarr updated through the update check.

When pinning a LinuxServer image, check the tag against the `latest`
digest, not the highest build number: LinuxServer restarts its build
counter (Sonarr's `-ls4` is newer than `-ls329`).

To publish a change: edit `defs/`, let `check.yml` pass, then the
maintainer runs `scripts/sign.sh KEY`, commits and pushes `site/`.

Later: new apps (one per pull request, with the tested tag), a page at the
site root that lists the apps for people, and re-signing before 10 May 2027
(the weekly check fails from 10 April).
