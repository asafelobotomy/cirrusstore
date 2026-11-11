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
Before the first publication (CirrusUX ROADMAP §5, step 2):
1. ~~Create the public GitHub repository, Pages from GitHub Actions,
   private vulnerability reporting~~: done 11 November 2026.
2. Bring `defs/` up to date: newest stable tag and digest for each of the
   11 apps that came from CirrusUX. Checked on 11 November 2026: Home
   Assistant moved to 2026.11.1 and Nextcloud's rebuilt 35.0.2-apache got
   its new digest; the other nine were already newest. Picard moved from
   mikenye/picard (stopped at 2.13.3) to jlesage/musicbrainz-picard
   (Picard 3.0.4, amd64 and arm64). Nothing was installed from the old
   image, so nobody needs moving over. Each app still needs trying on a test
   machine (install, open, update, remove). The first wave of new apps (qBittorrent, SABnzbd,
   Sonarr, Radarr, Lidarr, Prowlarr, Bazarr, Seerr) was added on
   11 November 2026: images run and answer their checks under Podman, but
   none has been installed through a CirrusUX panel yet.
3. The maintainer signs the first site (`scripts/sign.sh`), commits and
   pushes `site/`; `pages.yml` publishes it.
4. Check the live site: `curl` `index.json`, and run
   `.tools/cirrusstore-v0.7.1 verify -pub cirrusstore.pub` against a
   download of it. Then on a CirrusUX panel press **Check CirrusStore** and
   install one app from the official source.
5. Note in CirrusUX's ROADMAP that the official catalogue is published.

Later: new apps (one per pull request, with the tested tag), a page at the
site root that lists the apps for people, and a reminder to re-sign before
the 180 days run out (the weekly check already fails 30 days ahead).
