import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open, rectangle, shell, whenHyper } from "./utils";

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
          {
            key_code: "left_shift",
            modifiers: [
              "left_command",
              "left_control",
              "left_option",
            ],
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
  {
    "description": "Change hyper-(jikl) to (←↑↓→) keys",
    "manipulators": [
      {
        "from": {
          "key_code": "h",
          modifiers: whenHyper(),
        },
        "to": [
          {
            "key_code": "left_arrow"
          }
        ],
        "type": "basic"
      },
      {
        "from": {
          "key_code": "k",
          modifiers: whenHyper(),
        },
        "to": [
          {
            "key_code": "up_arrow"
          }
        ],
        "type": "basic"
      },
      {
        "from": {
          "key_code": "j",
          modifiers: whenHyper(),
        },
        "to": [
          {
            "key_code": "down_arrow"
          }
        ],
        "type": "basic"
      },
      {
        "from": {
          "key_code": "l",
          modifiers: whenHyper(),
        },
        to: [
          {
            key_code: "right_arrow",
          },
        ],
        "type": "basic"
      }
    ]
  },
  ...createHyperSubLayers({
    o: {
      g: app("Arc"),
      t: app("Iterm"),
      v: app("Cursor"),
      n: app("Obsidian"),
      w: app("WhatsApp"),
      s: app("Sublime Text"),
      m: app("Youtube Music"),
      p: app("Podcasts"),

    },
    // r = "Raycast"
    r: {
      c: open("raycast://extensions/raycast/system/open-camera"),
      p: open("raycast://extensions/raycast/raycast/confetti"),
      1: open("raycast://extensions/VladCuciureanu/toothpick/connect-favorite-device-1"),
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