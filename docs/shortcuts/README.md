# Shortcuts cheatsheet

`shortcuts.html` is built from `data.json`, which `bin/gen-shortcuts` regenerates from Karabiner (`config/karabiner/karabiner.json`), Crux (`manifest.json` commands, `overlay.js` VERB_KEYS), the Raycast chrome-tabs extension, and the tmux/Ghostty/zsh home-manager modules.
`manual.json` holds the only hand-kept parts: the Crux palette's in-palette keys, Raycast `Keyboard.Shortcut.Common` values, a few label overrides, and the "most used" selectors.
Run `just shortcuts` (regenerate + check + open); `yarn build` in `config/karabiner` also regenerates it.
