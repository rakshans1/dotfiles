import fs from "fs";
import { KarabinerRules } from "./types";
import { createHyperSubLayers, app, open,  shell, key, openLink } from "./utils";

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
  {
    // option + cmd + h/j/k/l -> option + cmd + left/down/up/right arrow
    description: "Option + Command + h -> Option + Command + Left Arrow",
    manipulators: [
      {
        from: {
          key_code: "h",
          modifiers: {
            mandatory: ["left_option", "left_command"],
          },
        },
        to: [
          {
            key_code: "left_arrow",
            modifiers: ["left_option", "left_command"],
          },
        ],
        type: "basic",
      },
      {
        from: {
          key_code: "l",
          modifiers: {
            mandatory: ["left_option", "left_command"],
          },
        },
        to: [
          {
            key_code: "right_arrow",
            modifiers: ["left_option", "left_command"],
          },
        ],
        type: "basic",
      },
      {
        from: {
          key_code: "j",
          modifiers: {
            mandatory: ["left_option", "left_command"],
          },
        },
        to: [
          {
            key_code: "down_arrow",
            modifiers: ["left_option", "left_command"],
          },
        ],
        type: "basic",
      },
      {
        from: {
          key_code: "k",
          modifiers: {
            mandatory: ["left_option", "left_command"],
          },
        },
        to: [
          {
            key_code: "up_arrow",
            modifiers: ["left_option", "left_command"],
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
    n: app("Obsidian"),
    m: app("Youtube Music"),
    p: app("Podcasts"),
    d: app("Discord"),
    t: app("Iterm"),
    v: {
      p: key("p", ["left_shift", "left_command"]),
      alone: app("Cursor"),
    },
    g: {
      m: openLink("Google Chrome", "https://maps.google.com", false),
      alone: app("Google Chrome"),
    },
    f: {
      d: open("~/Downloads"),
      p: open("~/projects"),
      m: open("~/Music"),
      t: open("~/torrents"),
      w: open("~/workspace"),
      alone: app("Finder")
    },
    b: {
      t: openLink("Arc", "https://x.com", true),
      c: openLink("Arc", "https://claude.ai", true),
      e: openLink("Arc", "https://mail.google.com", true),
      g: openLink("Arc", "https://github.com", false),
      s: openLink("Arc", "https://app.slack.com/client/TNJRQ2H0E", true),
      alone: app("Arc")
    },
    y: {
      h: openLink("Google Chrome", "https://www.youtube.com/feed/history"),
      alone: openLink("Google Chrome", "https://www.youtube.com")
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