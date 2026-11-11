# CirrusStore

The official app catalogue for [CirrusUX](https://github.com/asafelobotomy/CirrusUX),
the self-hosting web panel. Panels fetch it from
`https://asafelobotomy.github.io/cirrusstore/` when their owner presses
**Check CirrusStore**, check every signature against the key built into
CirrusUX, and offer the apps it lists. New apps and newer image versions
arrive this way without waiting for a CirrusUX release.

## Status

Not published yet. The public key is in CirrusUX since 0.7.1; the first
signed site is still to come. What is left is in [AGENTS.md](AGENTS.md),
"Open work".

## How it fits together

```
defs/<id>.json         app definitions: what people edit and review
site/                  the signed catalogue, served by Pages as it is
  index.json(.sig)       the list of apps, with serials
  apps/<id>.json(.sig)   each definition in a signed envelope
cirrusstore.pub        the official public key (the same as CirrusUX's
                       internal/store/official.pub)
cirrusux.env           the CirrusUX release whose cirrusstore tool is used
scripts/
  tool.sh              builds that tool from the pinned tag and commit
  check.sh             checks defs/ and site/ without the signing key
  sign.sh              signs defs/ into site/, with the offline key
```

The definition format, envelopes, serials and expiry are described in
CirrusUX's [docs/APPS.md](https://github.com/asafelobotomy/CirrusUX/blob/main/docs/APPS.md).
In short:

- A definition can only say what CirrusUX runs safely. Unknown fields are
  refused, and images are pinned by tag and `sha256` digest, never
  `latest`.
- Each file in `site/` is signed with Ed25519. A panel accepts it only if
  the signature matches the official key, the source is `cirrusstore`, it
  hasn't expired, and its serial is no older than one it has seen.
- Signatures expire after 180 days, so a catalogue that stops being looked
  after stops offering apps. Installed apps keep running.

## Changing the catalogue

Anyone can propose an app or a new version: see
[CONTRIBUTING.md](CONTRIBUTING.md). A pull request changes `defs/` only.
CI checks it with a throwaway key, so it doesn't need the real one.

Publishing is the maintainer's step, on a machine with the offline key:

```bash
scripts/sign.sh /media/offline/cirrusstore.key
git diff --stat site/        # one envelope per changed app, and the index
git add site && git commit -m 'Sign the catalogue' && git push
```

Pushing `site/` to `main` runs `.github/workflows/pages.yml`, which checks
the site again and publishes it. A weekly check fails a month before the
signatures expire; re-sign then with the same command.

## Built-in apps

CirrusUX also carries its own copies of these definitions
(`internal/catalogue/apps/`), so a panel works with no network. `defs/`
started as a copy of those from v0.7.1. Once a panel has checked
CirrusStore, a definition here replaces the built-in one with the same id.
The two may drift apart; that is expected, and the built-in copies only
change with a CirrusUX release.

## Licence

GNU AGPL 3.0 or later, as CirrusUX; see `LICENSE`.
