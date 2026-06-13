import fs from "fs";
import { KarabinerRules, KeyCode, Manipulator } from "./types";
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

const numericJumpKeys: KeyCode[] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

function appTabJumpManipulators(
	appName: string,
	bundleIdentifiers: string[],
): Manipulator[] {
	return numericJumpKeys.map((key) => ({
		type: "basic",
		description: `${appName}: Right Option + ${key} -> Command + ${key}`,
		from: {
			key_code: key,
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [{ key_code: key, modifiers: ["left_command"] }],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: bundleIdentifiers,
			},
		],
	}));
}

const tmuxWindowJumpManipulators: Manipulator[] = numericJumpKeys.map((key) => ({
	type: "basic",
	description: `Ghostty: Right Option + ${key} -> tmux window ${key}`,
	from: {
		key_code: key,
		modifiers: { mandatory: ["right_option"], optional: ["any"] },
	},
	to: [
		{
			shell_command: `/Users/rakshan/.nix-profile/bin/tmux select-window -t ${key}`,
		},
	],
	conditions: [
		{
			type: "frontmost_application_if",
			bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
		},
	],
}));

const tmuxBufferManipulators: Manipulator[] = [
	{
		type: "basic",
		description: "Ghostty: Right Option + [ -> tmux copy mode",
		from: {
			key_code: "open_bracket",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command: "/Users/rakshan/.nix-profile/bin/tmux copy-mode",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + ] -> tmux paste buffer",
		from: {
			key_code: "close_bracket",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command: "/Users/rakshan/.nix-profile/bin/tmux paste-buffer",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + , -> tmux swap window left",
		from: {
			key_code: "comma",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"/Users/rakshan/.nix-profile/bin/tmux swap-window -t -1 -d",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + . -> tmux swap window right",
		from: {
			key_code: "period",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"/Users/rakshan/.nix-profile/bin/tmux swap-window -t +1 -d",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + \\ -> tmux prefix v",
		from: {
			key_code: "backslash",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{ key_code: "b", modifiers: ["left_control"] },
			{ key_code: "v" },
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + - -> tmux prefix V",
		from: {
			key_code: "hyphen",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{ key_code: "b", modifiers: ["left_control"] },
			{ key_code: "v", modifiers: ["left_shift"] },
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + z -> tmux zoom pane",
		from: {
			key_code: "z",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command: "/Users/rakshan/.nix-profile/bin/tmux resize-pane -Z",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + i -> copy tmux pane id",
		from: {
			key_code: "i",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"/Users/rakshan/.nix-profile/bin/tmux display-message -p '#{pane_id}' | /usr/bin/tr -d '\\n' | /usr/bin/pbcopy",
			},
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + n -> tmux prefix c",
		from: {
			key_code: "n",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{ key_code: "b", modifiers: ["left_control"] },
			{ key_code: "c" },
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
	{
		type: "basic",
		description: "Ghostty: Right Option + x -> tmux prefix x",
		from: {
			key_code: "x",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{ key_code: "b", modifiers: ["left_control"] },
			{ key_code: "x" },
		],
		conditions: [
			{
				type: "frontmost_application_if",
				bundle_identifiers: ["^com\\.mitchellh\\.ghostty$"],
			},
		],
	},
];

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
		description: "Right Option: current app numeric jump and tmux buffer controls",
		manipulators: [
			...tmuxWindowJumpManipulators,
			...tmuxBufferManipulators,
			...appTabJumpManipulators("Chrome", ["^com\\.google\\.Chrome$"]),
			...appTabJumpManipulators("Arc", ["^company\\.thebrowser\\.Browser$"]),
			...appTabJumpManipulators("Obsidian", ["^md\\.obsidian$"]),
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
