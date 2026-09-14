# Picotron external editor template

## What this is

A minimal Picotron example for editing Lua in VS Code or another external
editor. Normal Lua files live outside the cartridge, are split across multiple
files, and are copied into `/ram/cart` when the cartridge starts. Picotron-native
assets stay in the `.p64` cartridge.

The demo is intentionally just a movable 16x16 sprite: a plain filled circle
controlled with the directional buttons. Lua source lives externally in `src/`;
the player sprite is stored in `sample.p64` as a normal Picotron gfx asset.
The code draws sprite index `001` (numeric `1` in Lua), demonstrating the
separation between external source and cartridge-native assets.

The supplied cartridge already contains the circle at sprite `001`, drawn and
saved in Picotron. Its visibility, movement, and the external multi-file Lua
workflow have been tested successfully in Picotron.

## Quick start

1. Clone this repository, or create a new repository with **Use this template**.
2. Place the project under Picotron's `/projects/` directory.
3. If your project folder is not named `picotron-external-editor-template`,
   open `sample.p64` in Picotron and update the `cp()` source path in the
   cartridge's root `main.lua`.
4. Open `sample.p64` in Picotron and press Ctrl+R.
5. Edit files in `src/` with your external editor, save them, then press Ctrl+R
   in Picotron to reload.

## Project structure

```text
picotron-external-editor-template/
├── .gitignore
├── LICENSE
├── sample.p64
├── src/
│   ├── main.lua
│   ├── player.lua
│   └── render.lua
└── README.md
```

- `sample.p64`: Picotron cartridge, native assets, and tiny root bootstrap.
- `src/`: external development source, edited in VS Code or another editor.
  `main.lua` coordinates initialization, updates, and drawing; `player.lua`
  owns position and input; `render.lua` selects sprite index 1 and draws it.
- `/ram/cart/src/`: runtime copy created by `cp()` when the cartridge starts.
  This is **not another development source directory**; edit the external files.
- `.gitignore`: ignores local Picotron directory metadata (`/.info.pod`).

## How it works

Place or clone this folder as `picotron-external-editor-template` under the host
directory mapped to Picotron's `/projects/`. In Picotron, load
`/projects/picotron-external-editor-template/sample.p64`, then run it with Ctrl+R.

The root `main.lua` inside `sample.p64` contains:

```lua
-- Copy external source files into the cartridge during development.
-- Disable this cp() call before distributing a standalone cartridge.
cp("/projects/picotron-external-editor-template/src", "src")

include("src/main.lua")

game_init()

function _update()
  game_update()
end

function _draw()
  game_draw()
end
```

```text
external src/
    |
    | cp()
    v
/ram/cart/src/
    |
    | include()
    v
running game
```

`src/main.lua` then includes `src/player.lua` and `src/render.lua`.
The bootstrap explicitly calls `game_init()` after those files are included.

The source path `/projects/picotron-external-editor-template/src` must match
the actual project folder inside Picotron's `/projects/`. **If you rename the
folder or clone under another name, update the source path in the cartridge's
`cp()` call** and save the cartridge in Picotron.

## Development workflow

1. Open `src/*.lua` in VS Code or another external editor.
2. Edit the source.
3. Save the file normally in that editor.
4. Return to Picotron.
5. Press Ctrl+R.
6. The cartridge restarts.
7. The bootstrap copies the latest external `src/` into `/ram/cart/src/`.
8. The new code runs.

```text
Lua source: external editor save -> Picotron Ctrl+R
```

Picotron Ctrl+S is **not required merely to test an external Lua edit**.

## Asset workflow

Picotron-native assets such as gfx, map, and sfx remain inside `sample.p64`.
The supplied sample already contains a simple 16x16 circle at sprite `001`.
In Lua, `player_sprite = 1` selects that native sprite.

To edit or replace the player art:

1. Load `/projects/picotron-external-editor-template/sample.p64` in Picotron.
2. Open the gfx editor and edit sprite `001` as desired.
3. Press Ctrl+S in Picotron to save the updated asset into `sample.p64`.

No Lua source change is needed. After editing any native asset, use Ctrl+S
in Picotron to save it in the cartridge.

```text
Lua:
external editor save -> Picotron Ctrl+R

Assets:
Picotron edit -> Picotron Ctrl+S
```

**Do not press Ctrl+R before saving unsaved asset edits in Picotron.**

## Gotcha: why destination "src" matters

In the setup this workflow was originally tested with,
`cp("/projects/.../src", ".")` copied the **contents** of `src` directly into
`/ram/cart`, producing:

```text
/ram/cart/main.lua
/ram/cart/player.lua
/ram/cart/render.lua
```

This template intentionally uses `cp("/projects/.../src", "src")` so the
runtime layout is:

```text
/ram/cart/
├── main.lua          (cartridge bootstrap)
└── src/
    ├── main.lua
    ├── player.lua
    └── render.lua
```

This describes the tested behavior for this workflow, not a guarantee about
every Picotron version or future implementation.

## Standalone / release cartridge

The supplied `sample.p64` already contains the current `src/` snapshot, copied
from the external source with Ctrl+R and then saved in Picotron with Ctrl+S.

During development, the active `cp()` call still refreshes `/ram/cart/src/` from
`/projects/picotron-external-editor-template/src` on every start. External `src/`
remains the development source of truth while `cp()` is active. The saved
snapshot does not make the template standalone: it still depends on that
external directory until the development copy call is disabled.

To prepare a standalone cartridge:

1. Save the desired external Lua files and run the development cartridge so
   they are copied into `/ram/cart/src/`.
2. Save the cartridge in Picotron to update its stored `src/` snapshot to that
   desired version.
3. In the cartridge's root `main.lua`, comment out or remove the development
   `cp()` line. Keep `include("src/main.lua")` and the initialization/callbacks.
4. Save the cartridge again to persist the bootstrap change. You can save the
   release as a separate cartridge to retain the development version.
5. Reload and test that saved cartridge with the external source folder
   temporarily unavailable. Confirm the circle is visible and movement works.

GitHub and cloning do not perform these standalone preparation steps.

## Why use this workflow?

- Normal Lua syntax highlighting and file navigation in your editor.
- Easier Git diffs and multi-file organization.
- A smaller, cleaner cartridge bootstrap.
- Picotron still manages native assets.

## Troubleshooting

**`could not include src/main.lua`**

Check the `cp()` source path, that the project exists under `/projects/`,
that the destination is `"src"`, and that external `src/main.lua` exists.
Inspect `/ram/cart/src/` if necessary.

**External Lua changes do not appear**

Save the file in the external editor, press Ctrl+R in Picotron, and verify
that `cp()` points to the current repository directory.

**The cartridge only works while the external source folder exists**

The development `cp()` line is still active. Make sure the desired `src/`
snapshot exists inside the cartridge, save it, disable the `cp()` line,
save again, and test as described above.

## Disclaimer

This is an unofficial community project and is not affiliated with or endorsed by Lexaloffle Games LLP.

The workflow documented here is provided to the best of the author's knowledge and is based on behavior tested with the author's Picotron setup. Picotron behavior may change between versions, so verify the workflow with your own environment before relying on it.

This project is provided as-is, without warranty of any kind. See the LICENSE file for details.

Picotron is developed by Lexaloffle Games LLP.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
