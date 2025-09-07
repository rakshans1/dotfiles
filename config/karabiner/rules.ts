import fs from "fs";
import { KarabinerRules } from "./types";
import {
	createHyperSubLayers,
	app,
	open,
	shell,
	key,
	openLink,
	openPath,
	openArcSpace,
} from "./utils";

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
	{
		description: "CMD+S/H/J/K/L/W to CTRL+S/H/J/K/L/W in ghostty",
		manipulators: [
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "s",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "s", modifiers: ["left_control"] }],
				type: "basic",
			},
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "h",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "h", modifiers: ["left_control"] }],
				type: "basic",
			},
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "j",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "j", modifiers: ["left_control"] }],
				type: "basic",
			},
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "k",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "k", modifiers: ["left_control"] }],
				type: "basic",
			},
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "l",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "l", modifiers: ["left_control"] }],
				type: "basic",
			},
			{
				conditions: [
					{
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
						type: "frontmost_application_if",
					},
				],
				from: {
					key_code: "w",
					modifiers: { mandatory: ["left_command"] },
				},
				to: [{ key_code: "w", modifiers: ["left_control"] }],
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
		e: app("Sublime Text"),
		s: {
			h: key("grave_accent_and_tilde", ["left_command"]),
			l: key("grave_accent_and_tilde", ["left_shift", "left_command"]),
			1: shell`~/dotfiles/bin/bluetooth-connect "AirPod"`,
		},
		w: app("WhatsApp"),
		n: {
			d: open(
				"'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-day'",
			),
			w: open(
				"'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-week'",
			),
			m: open(
				"'obsidian://adv-uri?vault=brain&commandid=journals:journal:calendar:open-month'",
			),
			alone: app("Obsidian"),
		},
		m: app("Youtube Music"),
		d: {
			a: key("a", ["left_command"]),
			c: key("c", ["left_command"]),
			v: key("v", ["left_command"]),
			h: key("left_arrow", ["left_command", "left_option"]),
			l: key("right_arrow", ["left_command", "left_option"]),
			j: key("down_arrow", ["left_command", "left_option"]),
			k: key("up_arrow", ["left_command", "left_option"]),
			alone: app("Discord"),
		},
		t: {
			d: shell`~/.nix-profile/bin/tmux switch-client -t dotfiles`,
			p: shell`~/.nix-profile/bin/tmux switch-client -t projects`,
			w: shell`~/.nix-profile/bin/tmux switch-client -t work`,
			alone: app("Ghostty"),
		},
		v: {
			// Open git in side panel
			g: key("g", ["left_shift", "left_control"]),
			// Open file in side panel
			f: key("f", ["left_shift", "left_option"]),
			// Search symbols
			s: key("o", ["left_shift", "left_command"]),
			// Open Command Palette
			p: key("p", ["left_shift", "left_command"]),
			alone: app("Cursor"),
		},
		g: {
			m: openLink("Google Chrome", "https://maps.google.com", false),
			alone: app("Google Chrome"),
		},
		f: {
			d: openPath("~/Downloads"),
			p: openPath("~/projects"),
			m: openPath("~/Music"),
			t: openPath("~/torrents"),
			w: openPath("~/workspace"),
			h: key("left_arrow", ["left_shift"]),
			l: key("right_arrow", ["left_shift"]),
			j: key("down_arrow", ["left_shift"]),
			k: key("up_arrow", ["left_shift"]),
			alone: app("Finder"),
		},
		b: {
			t: openLink("Arc", "https://x.com", true),
			c: openLink("Arc", "https://claude.ai", true),
			e: openLink("Arc", "https://mail.google.com", true),
			g: openLink("Arc", "https://github.com", false),
			s: openLink("Arc", "https://app.slack.com/client/TNJRQ2H0E", true),
			m: openLink("Arc", "https://m.localhost", true),
			r: openLink("Arc", "https://www.reddit.com", true),
			1: openArcSpace("Work"),
			2: openArcSpace("Personal"),
			3: openArcSpace("Reading"),
			alone: app("Arc"),
		},
		y: {
			h: openLink("Google Chrome", "https://www.youtube.com/feed/history"),
			alone: openLink("Google Chrome", "https://www.youtube.com"),
		},
		// r = "Raycast"
		r: {
			c: open("raycast://extensions/raycast/system/open-camera"),
			p: open("raycast://extensions/raycast/raycast/confetti"),
			q: open("raycast://extensions/raycast/raycast/search-quicklinks"),
			alone: app("Raycast"),
		},
	}),
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
					virtual_hid_keyboard: { keyboard_type_v2: "ansi" },
					complex_modifications: {
						rules: rules,
					},
				},
			],
		},
		null,
		2,
	),
);
