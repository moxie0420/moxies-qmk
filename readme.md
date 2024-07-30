# Moxies QMK
This Repository contains my build of qmk though rn it doesnt have much customization yet

## Supported Keyboards

* [GMMK 2](/keyboards/gmmk/gmmk2)
* [GMMK PRO](/keyboards/gmmk/pro)

## Commands

All commands are run from the root of the project, from a terminal:

| Command | Action                               |
| :------ | :----------------------------------- |
| `build` | builds qmk for the selected keyboard |
| `clean` | Clean up build artifacts             |
| `flash` | flash firmware to the keyboard       |

### switching boards
to switch boards you can change build.exec or flash.exec in [flake.nix](/flake.nix) to the specific build and flash commands for your keyboard
