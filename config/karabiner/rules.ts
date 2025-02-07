import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open, chrome, rectangle, shell, whenHyper, key } from "./utils";

const rules: KarabinerRules[] = [
  // Define the Hyper key itself
  {
    description: "Hyper Key (⌃⌥⇧⌘)",
    manipulators: [
      {
        description: "Caps Lock -> Hyper Key",
        from: {
          key_code: "caps_lock",
          modifiers: {
            optional: ["any"],
          },
        },
        to: [
          {
            set_variable: {
              name: "hyper",
              value: 1,
            },
          },
        ],
        to_after_key_up: [
          {
            set_variable: {
              name: "hyper",
              value: 0,
            },
          },
        ],
        to_if_alone: [
          {
            key_code: "escape",
          },
        ],
        type: "basic",
      },
    ],
  },
  ...createHyperSubLayers({
    h: key("left_arrow"),
    j: key("down_arrow"),
    k: key("up_arrow"),
    l: key("right_arrow"),
    u: key("page_down"),
    i: key("page_up"),
    s: app("Sublime Text"),
    w: app("WhatsApp"),
    g: app("Google Chrome"),
    v: app("Cursor"),
    n: app("Obsidian"),
    m: app("Youtube Music"),
    p: app("Podcasts"),
    d: app("Discord"),
    t: app("Iterm"),
    f: app("Finder"),
    b: {
      t: open("https://twitter.com"),
      alone: app("Arc")
    },
    y: {
      h: chrome("https://www.youtube.com/feed/history")
    },
    // r = "Raycast"
    r: {
      c: open("raycast://extensions/raycast/system/open-camera"),
      p: open("raycast://extensions/raycast/raycast/confetti"),
      1: open("raycast://extensions/VladCuciureanu/toothpick/connect-favorite-device-1"),
      alone: app("Raycast"),
    }
  })
];

fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: {
        show_in_menu_bar: false,
      },
      profiles: [
        {
          name: "Default",
          "virtual_hid_keyboard": { "keyboard_type_v2": "ansi" },
          complex_modifications: {
            rules,
          },
        },
      ],
    },
    null,
    2
  )
);