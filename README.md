# HoT-VAX

A drag-and-drop macOS droplet app that strips the `com.apple.quarantine`
extended attribute — the thing that triggers "*App* is damaged and can't be
opened" / "cannot be opened because the developer cannot be verified" —
from unsigned apps and files you build or receive in-house.

## Usage

- **Drag and drop**: drop one or more `.app` bundles, files, or folders onto
  `HoT-VAX.app`.
- **Double-click**: launch `HoT-VAX.app` directly and pick files/folders from
  a picker.

Under the hood it runs `xattr -rd com.apple.quarantine` recursively on each
item, then shows a summary dialog of what was vaccinated.

## Contents

- `HoT-VAX.app` — the compiled, ready-to-run droplet app.
- `HoT-VAX.applescript` — the AppleScript source.
- `HoT-VAX.png` — the app icon artwork.

## Installing

Download the latest `.dmg` from the [Releases](../../releases) page, open
it, and drag `HoT-VAX.app` into `Applications`.

## Building from source

```sh
osacompile -o HoT-VAX.app HoT-VAX.applescript
```
