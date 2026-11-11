# Contributing to CirrusStore

Thanks for helping. Every app here is one JSON definition in `defs/`, in
the format CirrusUX's
[docs/APPS.md](https://github.com/asafelobotomy/CirrusUX/blob/main/docs/APPS.md)
describes.

## Adding an app or a new version

1. Edit or add `defs/<id>.json`, with the newest stable tag and its digest:

   ```bash
   skopeo inspect --raw docker://docker.io/OWNER/NAME:TAG | sha256sum
   ```

2. Run `scripts/check.sh` (needs git and Go). It refuses anything CirrusUX
   would refuse, in plain words.
3. Install it from a test CirrusUX, open it, then update and remove it.
4. Open a pull request saying which tag you tested, on which runtime
   (Podman or Docker) and CPU.

Don't touch `site/`: the maintainer signs it after merging. Apps that need
several containers can't be described yet. App ids are unique across all
sources, so choose a plain, distinct one.

By sending a change, you agree it's released under the GNU AGPL 3.0 or
later, as the rest of the repository.
