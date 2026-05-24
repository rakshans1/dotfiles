import fs from "fs";
import { KarabinerRules } from "./types";
import {
	app,
	createHyperSubLayers,
	key,
	open,
	openArcSpace,
	openLink,
	openPath,
	shell,
} from "./utils";

// ──────── Hold/tap tunables ────────
const HOLD_TIME = 150; // letter holds (a/s/d/f, t)
const TAP_TIMEOUT = 400; // max ms to count as tap

const hrmParams = {
	"basic.to_if_held_down_threshold_milliseconds": HOLD_TIME,
	"basic.to_if_alone_timeout_milliseconds": TAP_TIMEOUT,
};

const notHyperHeld = {
	type: "variable_if" as const,
	name: "hyper",
	value: 0,
};

const rules: KarabinerRules[] = [
	// Right Command is the Hyper trigger. Tap alone does nothing.
	{
		description: "Right Command -> Hyper",
		manipulators: [
			{
				description: "Hold Right Command for Hyper",
				from: {
					key_code: "right_command",
					modifiers: { optional: ["any"] },
				},
				to: [{ set_variable: { name: "hyper", value: 1 } }],
				to_after_key_up: [{ set_variable: { name: "hyper", value: 0 } }],
				to_if_alone: [{ key_code: "vk_none" }],
				type: "basic",
			},
		],
	},

	{
		description: "Hyper + Escape: reset Karabiner variables",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "escape", modifiers: { optional: ["any"] } },
				to: [
					{ set_variable: { name: "hyper", value: 0 } },
					{ set_variable: { name: "spc_sublayer", value: 0 } },
					{ set_variable: { name: "a_held", value: 0 } },
					{ set_variable: { name: "s_held", value: 0 } },
					{ set_variable: { name: "d_held", value: 0 } },
					{ set_variable: { name: "f_held", value: 0 } },
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
		],
	},

	// Cmd+Opt+h/j/k/l -> Cmd+Opt+arrows
	{
		description: "Option + Command + h/j/k/l -> arrows",
		manipulators: [
			{
				from: {
					key_code: "h",
					modifiers: { mandatory: ["left_option", "left_command"] },
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
					modifiers: { mandatory: ["left_option", "left_command"] },
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
					modifiers: { mandatory: ["left_option", "left_command"] },
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
					modifiers: { mandatory: ["left_option", "left_command"] },
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
		description: "Hyper + 1/2/3: tmux sessions",
		manipulators: [
			{
				type: "basic",
				description: "Hyper + 1 -> tmux work",
				from: { key_code: "1", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/usr/bin/open -a 'Ghostty.app'; /Users/rakshan/.nix-profile/bin/tmux switch-client -t work",
					},
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
			{
				type: "basic",
				description: "Hyper + 2 -> tmux projects",
				from: { key_code: "2", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/usr/bin/open -a 'Ghostty.app'; /Users/rakshan/.nix-profile/bin/tmux switch-client -t projects",
					},
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
			{
				type: "basic",
				description: "Hyper + 3 -> tmux personal",
				from: { key_code: "3", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/usr/bin/open -a 'Ghostty.app'; /Users/rakshan/.nix-profile/bin/tmux switch-client -t personal",
					},
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
		],
	},

	{
		description: "Hyper + comma/period/brackets: current app navigation",
		manipulators: [
			{
				type: "basic",
				description: "Ghostty: Hyper + comma -> tmux previous window",
				from: { key_code: "comma", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux previous-window",
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
			},
			{
				type: "basic",
				description: "Ghostty: Hyper + period -> tmux next window",
				from: { key_code: "period", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux next-window",
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
			},
			{
				type: "basic",
				description: "Chrome: Hyper + comma -> previous tab",
				from: { key_code: "comma", modifiers: { optional: ["any"] } },
				to: [{ key_code: "tab", modifiers: ["left_control", "left_shift"] }],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.google\\.Chrome$"],
					},
				],
			},
			{
				type: "basic",
				description: "Chrome: Hyper + period -> next tab",
				from: { key_code: "period", modifiers: { optional: ["any"] } },
				to: [{ key_code: "tab", modifiers: ["left_control"] }],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.google\\.Chrome$"],
					},
				],
			},
			{
				type: "basic",
				description: "Arc: Hyper + comma -> next tab",
				from: { key_code: "comma", modifiers: { optional: ["any"] } },
				to: [
					{
						key_code: "down_arrow",
						modifiers: ["left_option", "left_command"],
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^company\\.thebrowser\\.Browser$"],
					},
				],
			},
			{
				type: "basic",
				description: "Arc: Hyper + period -> previous tab",
				from: { key_code: "period", modifiers: { optional: ["any"] } },
				to: [
					{ key_code: "up_arrow", modifiers: ["left_option", "left_command"] },
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^company\\.thebrowser\\.Browser$"],
					},
				],
			},
			{
				type: "basic",
				description: "Arc: Hyper + [ -> previous space",
				from: { key_code: "open_bracket", modifiers: { optional: ["any"] } },
				to: [
					{
						key_code: "left_arrow",
						modifiers: ["left_option", "left_command"],
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^company\\.thebrowser\\.Browser$"],
					},
				],
			},
			{
				type: "basic",
				description: "Arc: Hyper + ] -> next space",
				from: { key_code: "close_bracket", modifiers: { optional: ["any"] } },
				to: [
					{
						key_code: "right_arrow",
						modifiers: ["left_option", "left_command"],
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^company\\.thebrowser\\.Browser$"],
					},
				],
			},
			{
				type: "basic",
				description: "Obsidian: Hyper + comma -> previous tab",
				from: { key_code: "comma", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Applications/Obsidian.app/Contents/MacOS/Obsidian command id=workspace:previous-tab",
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^md\\.obsidian$"],
					},
				],
			},
			{
				type: "basic",
				description: "Obsidian: Hyper + period -> next tab",
				from: { key_code: "period", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Applications/Obsidian.app/Contents/MacOS/Obsidian command id=workspace:next-tab",
					},
				],
				conditions: [
					{ type: "variable_if", name: "hyper", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^md\\.obsidian$"],
					},
				],
			},
		],
	},

	{
		description: "Hyper + d/s + h/l: Ghostty tmux swap pane/window",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "h", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "~/.nix-profile/bin/tmux swap-pane -U" }],
				conditions: [
					{ type: "variable_if", name: "hyper_sublayer_d", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
			},
			{
				type: "basic",
				from: { key_code: "l", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "~/.nix-profile/bin/tmux swap-pane -D" }],
				conditions: [
					{ type: "variable_if", name: "hyper_sublayer_d", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
			},
			{
				type: "basic",
				from: { key_code: "h", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "~/.nix-profile/bin/tmux swap-window -t -1 -d" }],
				conditions: [
					{ type: "variable_if", name: "hyper_sublayer_s", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
			},
			{
				type: "basic",
				from: { key_code: "l", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "~/.nix-profile/bin/tmux swap-window -t +1 -d" }],
				conditions: [
					{ type: "variable_if", name: "hyper_sublayer_s", value: 1 },
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
					},
				],
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
			d: shell`~/dotfiles/bin/rr o daily`,
			w: shell`~/dotfiles/bin/rr o weekly`,
			m: shell`~/dotfiles/bin/rr o monthly`,
			p: shell`~/dotfiles/bin/rr o pin`,
			open_bracket: shell`~/dotfiles/bin/rr o toggle`,
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
			alone: app("Ghostty"),
		},
		v: {
			g: key("g", ["left_shift", "left_control"]),
			f: key("f", ["left_shift", "left_option"]),
			s: key("o", ["left_shift", "left_command"]),
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
		r: {
			c: open("raycast://extensions/raycast/system/open-camera"),
			p: open("raycast://extensions/raycast/raycast/confetti"),
			q: open("raycast://extensions/raycast/raycast/search-quicklinks"),
			alone: app("Raycast"),
		},
	}),

	// Home-row mods (gregorias pattern with retroactive emit + debug variables).
	{
		description: "a-hold = Cmd",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "a", modifiers: { optional: ["any"] } },
				conditions: [notHyperHeld],
				to_if_alone: [
					{ set_variable: { name: "a_held", value: 0 } },
					{ halt: true, key_code: "a" },
				],
				to_if_held_down: [
					{ key_code: "left_command" },
					{ set_variable: { name: "a_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "a_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "a" },
						{ set_variable: { name: "a_held", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: hrmParams,
			},
		],
	},
	{
		description: "s-hold = Opt",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "s", modifiers: { optional: ["any"] } },
				conditions: [notHyperHeld],
				to_if_alone: [
					{ set_variable: { name: "s_held", value: 0 } },
					{ halt: true, key_code: "s" },
				],
				to_if_held_down: [
					{ key_code: "left_option" },
					{ set_variable: { name: "s_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "s_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "s" },
						{ set_variable: { name: "s_held", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: hrmParams,
			},
		],
	},
	{
		description: "d-hold = Ctrl",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "d", modifiers: { optional: ["any"] } },
				conditions: [notHyperHeld],
				to_if_alone: [
					{ set_variable: { name: "d_held", value: 0 } },
					{ halt: true, key_code: "d" },
				],
				to_if_held_down: [
					{ key_code: "left_control" },
					{ set_variable: { name: "d_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "d_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "d" },
						{ set_variable: { name: "d_held", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: hrmParams,
			},
		],
	},
	{
		description: "f-hold = Shift + shift-nav (tmux window switch)",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "f", modifiers: { optional: ["any"] } },
				conditions: [notHyperHeld],
				to_if_alone: [
					{ set_variable: { name: "f_held", value: 0 } },
					{ halt: true, key_code: "f" },
				],
				to_if_held_down: [
					{ key_code: "left_shift" },
					{ set_variable: { name: "f_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "f_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "f" },
						{ set_variable: { name: "f_held", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: hrmParams,
			},
			{
				type: "basic",
				description: "f + h -> Shift+Left (tmux prev window)",
				from: { key_code: "h", modifiers: { optional: ["any"] } },
				to: [{ key_code: "left_arrow", modifiers: ["left_shift"] }],
				conditions: [{ type: "variable_if", name: "f_held", value: 1 }],
			},
			{
				type: "basic",
				description: "f + l -> Shift+Right (tmux next window)",
				from: { key_code: "l", modifiers: { optional: ["any"] } },
				to: [{ key_code: "right_arrow", modifiers: ["left_shift"] }],
				conditions: [{ type: "variable_if", name: "f_held", value: 1 }],
			},
		],
	},
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
