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
const tmuxNumericJumpKeys: KeyCode[] = [
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"0",
];

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

const tmuxWindowJumpManipulators: Manipulator[] = tmuxNumericJumpKeys.map((key) => ({
	type: "basic",
	description: `Ghostty: Right Option + ${key} -> tmux window ${key}`,
	from: {
		key_code: key,
		modifiers: { mandatory: ["right_option"], optional: ["any"] },
	},
	to: [
		{ key_code: "b", modifiers: ["left_control"] },
		{ key_code: key },
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
		description: "Ghostty: Right Option + a -> vigil sidebar toggle",
		from: {
			key_code: "a",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin /Users/rakshan/projects/rust/vigil/.nix-cargo/bin/vigil sidebar toggle",
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
		description: "Ghostty: Right Option + ; -> vigil cycle slide prev",
		from: {
			key_code: "semicolon",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin /Users/rakshan/projects/rust/vigil/.nix-cargo/bin/vigil swap --prev",
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
		description: "Ghostty: Right Option + ' -> vigil cycle slide next",
		from: {
			key_code: "quote",
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to: [
			{
				shell_command:
					"PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin /Users/rakshan/projects/rust/vigil/.nix-cargo/bin/vigil swap --next",
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

// Term (~/projects/swift/term): the same keys as the Ghostty/tmux rules above,
// driven through Term's prefix (Ctrl+B) or its control CLI.
const TERM_BUNDLE = "^dev\\.rakshan\\.term$";
const TERM_CTL = "/Users/rakshan/Applications/Term.app/Contents/MacOS/term-ctl";
const termFrontmost = `lsappinfo info -only bundleid "$(lsappinfo front)" | grep -q '"dev.rakshan.term"'`;

function termRopt(
	key: KeyCode,
	description: string,
	to: Manipulator["to"],
): Manipulator {
	return {
		type: "basic",
		description: `Term: Right Option + ${description}`,
		from: {
			key_code: key,
			modifiers: { mandatory: ["right_option"], optional: ["any"] },
		},
		to,
		conditions: [
			{ type: "frontmost_application_if", bundle_identifiers: [TERM_BUNDLE] },
		],
	};
}

const termPrefix = (key: KeyCode, shift = false): Manipulator["to"] => [
	{ key_code: "b", modifiers: ["left_control"] },
	shift ? { key_code: key, modifiers: ["left_shift"] } : { key_code: key },
];
const termCtl = (args: string): Manipulator["to"] => [
	{ shell_command: `${TERM_CTL} ${args}` },
];

const termRightOptionManipulators: Manipulator[] = [
	...tmuxNumericJumpKeys.map((key) =>
		termRopt(key, `${key} -> tab ${key}`, termPrefix(key)),
	),
	termRopt("backslash", "\\ -> split right", termPrefix("v")),
	termRopt("hyphen", "- -> split down", termPrefix("v", true)),
	termRopt("n", "n -> new tab", termPrefix("c")),
	termRopt("x", "x -> close pane", termPrefix("x")),
	termRopt("z", "z -> zoom pane", termCtl("zoom")),
	termRopt("open_bracket", "[ -> search", termCtl("search")),
	termRopt("close_bracket", "] -> paste", termCtl("paste")),
	termRopt("comma", ", -> move tab left", termCtl("move-tab left")),
	termRopt("period", ". -> move tab right", termCtl("move-tab right")),
	termRopt("i", "i -> copy `rr agent msg <agent>` for the focused pane", termCtl("copy-agent-msg")),
	termRopt("a", "a -> sidebar toggle", termCtl("sidebar")),
	// vigil swap (; ') is tmux-only; swallow so ESC-; / ESC-' never reach the pane.
	termRopt("semicolon", "; -> (none)", [{ key_code: "vk_none" }]),
	termRopt("quote", "' -> (none)", [{ key_code: "vk_none" }]),
];

// Hyper manipulators that apply only while Term is frontmost; listed before
// the Ghostty/global ones in the same rule so they win.
function termHyper(
	key: KeyCode,
	description: string,
	args: string,
	opts: { shift?: boolean; variable?: string } = {},
): Manipulator {
	return {
		type: "basic",
		description: `Term: Hyper + ${description}`,
		from: {
			key_code: key,
			modifiers: opts.shift
				? { mandatory: ["left_shift"], optional: ["any"] }
				: { optional: ["any"] },
		},
		to: termCtl(args),
		conditions: [
			{ type: "variable_if", name: opts.variable ?? "hyper", value: 1 },
			{ type: "frontmost_application_if", bundle_identifiers: [TERM_BUNDLE] },
		],
	};
}

// Skills live in the Raycast `skills` extension (private/raycast/extensions/skills),
// catalogued in brain/.config/skills/catalog.json. `paste` resolves a name or
// keyword and pastes the reference into the frontmost app; `open -g` keeps that
// app focused so the text lands where you were typing.
const skill = (nameOrKeyword: string) =>
	open(`-g "raycast://extensions/rakshan/skills/paste?arguments=${encodeURIComponent(JSON.stringify({ skill: nameOrKeyword }))}"`);

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
		description: "Hyper + a: vigil agent panel (global summon)",
		manipulators: [
			{
				type: "basic",
				description: "Hyper + a -> toggle vigil popup (open Ghostty if needed)",
				from: { key_code: "a", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin; if pgrep -qf '/vigil ui$'; then tmux display-popup -C; else /usr/bin/open -a 'Ghostty.app'; tmux display-popup -E -w 80% -h 60% '/Users/rakshan/projects/rust/vigil/.nix-cargo/bin/vigil ui'; fi",
					},
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
		],
	},

	{
		description: "Hyper + 1/2/3: tmux sessions",
		manipulators: [
			termHyper("1", "1 -> workspace work", "workspace work"),
			termHyper("2", "2 -> workspace projects", "workspace projects"),
			termHyper("3", "3 -> workspace personal", "workspace personal"),
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
		description: "Hyper + Shift + comma/period: Ghostty tmux move pane left/right",
		manipulators: [
			termHyper("comma", "Shift + comma -> swap pane prev", "swap-pane prev", { shift: true }),
			termHyper("period", "Shift + period -> swap pane next", "swap-pane next", { shift: true }),
			{
				type: "basic",
				description: "Ghostty: Hyper + Shift + comma -> tmux move pane left",
				from: {
					key_code: "comma",
					modifiers: { mandatory: ["left_shift"], optional: ["any"] },
				},
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux swap-pane -s '{left-of}'",
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
				description: "Ghostty: Hyper + Shift + period -> tmux move pane right",
				from: {
					key_code: "period",
					modifiers: { mandatory: ["left_shift"], optional: ["any"] },
				},
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux swap-pane -s '{right-of}'",
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
		],
	},

	{
		description: "Hyper + comma/period/brackets: current app navigation",
		manipulators: [
			termHyper("comma", "comma -> previous tab", "prev-tab"),
			termHyper("period", "period -> next tab", "next-tab"),
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
				description: "Chrome (vertical tabs): Hyper + comma -> next tab (down)",
				from: { key_code: "comma", modifiers: { optional: ["any"] } },
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
				description: "Chrome (vertical tabs): Hyper + period -> previous tab (up)",
				from: { key_code: "period", modifiers: { optional: ["any"] } },
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
		description: "Chrome: Cmd+Shift+C -> copy URL, Cmd+S -> vertical tabs, Hyper+K -> Crux switcher",
		manipulators: [
			{
				type: "basic",
				description: "Chrome: Cmd+Shift+C -> copy current URL to clipboard",
				from: {
					key_code: "c",
					modifiers: { mandatory: ["left_command", "left_shift"], optional: ["any"] },
				},
				to: [{ shell_command: "~/dotfiles/bin/chrome-copy-url" }],
				conditions: [
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.google\\.Chrome$"],
					},
				],
			},
			{
				type: "basic",
				description: "Chrome: Hyper(Right Cmd) + K -> Crux command palette (Cmd+Shift+K)",
				from: {
					key_code: "k",
					modifiers: { optional: ["any"] },
				},
				to: [{ key_code: "k", modifiers: ["left_command", "left_shift"] }],
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
				// Cmd+Shift+P died when crux collapsed its two palettes into one
				// (open-palette, Cmd+Shift+K — already on Hyper+K). Reused here for
				// cross-profile tab search, which the in-Chrome palette cannot do:
				// it only ever sees the profile it is running in. Deliberately not
				// scoped to Chrome, so it reaches you from Ghostty too.
				description: "Hyper(Right Cmd) + P -> Raycast: search Chrome tabs (both profiles)",
				from: {
					key_code: "p",
					modifiers: { optional: ["any"] },
				},
				to: [
					{
						shell_command: "/usr/bin/open -g raycast://extensions/rakshan/chrome-tabs/tabs",
					},
				],
				conditions: [{ type: "variable_if", name: "hyper", value: 1 }],
			},
			{
				type: "basic",
				description: "Chrome: Cmd+Shift+S -> Crux side panel (Cmd+Shift+U extension shortcut)",
				from: {
					key_code: "s",
					modifiers: { mandatory: ["left_command", "left_shift"], optional: ["any"] },
				},
				to: [{ key_code: "u", modifiers: ["left_command", "left_shift"] }],
				conditions: [
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.google\\.Chrome$"],
					},
				],
			},
			{
				type: "basic",
				description: "Chrome: Cmd+S -> toggle vertical tab bar",
				from: {
					key_code: "s",
					modifiers: { mandatory: ["left_command"], optional: ["any"] },
				},
				to: [{ shell_command: "~/dotfiles/bin/chrome-toggle-tabs" }],
				conditions: [
					{
						type: "frontmost_application_if",
						bundle_identifiers: ["^com\\.google\\.Chrome$"],
					},
				],
			},
		],
	},

	{
		description: "Right Option: current app numeric jump and tmux buffer controls",
		manipulators: [
			...termRightOptionManipulators,
			...tmuxWindowJumpManipulators,
			...tmuxBufferManipulators,
			...appTabJumpManipulators("Chrome", ["^com\\.google\\.Chrome$"]),
			...appTabJumpManipulators("Arc", ["^company\\.thebrowser\\.Browser$"]),
			...appTabJumpManipulators("Obsidian", ["^md\\.obsidian$"]),
		],
	},

	{
		description: "Hyper + s + h/l: Ghostty tmux swap window",
		manipulators: [
			termHyper("h", "s + h -> move tab left", "move-tab left", { variable: "hyper_sublayer_s" }),
			termHyper("l", "s + l -> move tab right", "move-tab right", { variable: "hyper_sublayer_s" }),
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

	{
		// Worklog's dictation hotkey, held for as long as you're speaking.
		// Karabiner holds the `to` chord for the life of the `from` key, so F5
		// is push-to-talk. Not ...+L, which is Worklog's own Open Library.
		description: "F5 (mic/dictation key) -> Cmd+Option+Control+D",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "f5", modifiers: { optional: ["any"] } },
				to: [
					{
						key_code: "d",
						modifiers: ["left_command", "left_option", "left_control"],
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
			// Tap Hyper+s: Term frontmost -> toggle Term's sidebar; otherwise the
			// vigil tmux sidebar.
			alone: shell`PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin; if lsappinfo info -only bundleid "$(lsappinfo front)" | grep -q '"dev.rakshan.term"'; then /Users/rakshan/Applications/Term.app/Contents/MacOS/term-ctl sidebar.toggle; else /Users/rakshan/projects/rust/vigil/.nix-cargo/bin/vigil sidebar toggle; fi`,
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
			// Tap Hyper+t: when Ghostty is frontmost, toggle the tmx
			// tmux-manager popup; otherwise just focus Ghostty (press again to
			// open the popup). Mirrors Hyper+a -> vigil.
			alone: shell`PATH=/Users/rakshan/.nix-profile/bin:/usr/bin:/bin; if lsappinfo info -only name "$(lsappinfo front)" | grep -q Ghostty; then if pgrep -qf '/tmx ui$'; then tmux display-popup -C; else tmux display-popup -E -w 80% -h 70% '/Users/rakshan/projects/rust/tmx/target/release/tmx ui'; fi; else /usr/bin/open -a 'Ghostty.app'; fi`,
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
			s: shell`~/dotfiles/bin/chrome-profile work "Profile 6" https://app.slack.com/client/TNJRQ2H0E`,
			alone: shell`~/dotfiles/bin/chrome-profile work "Profile 6"`,
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
			alone: shell`~/dotfiles/bin/chrome-profile personal Default`,
		},
		y: {
			h: openLink("Google Chrome", "https://www.youtube.com/feed/history"),
			alone: openLink("Google Chrome", "https://www.youtube.com"),
		},
		// Hyper + / : skills are slash commands, so slash is the key.
		slash: {
			d: skill("dl"),
			b: skill("bdevloop"),
			t: skill("tops"),
			l: skill("ll"),
			s: skill("ss"),
			m: skill("sm"),
			alone: open("-g raycast://extensions/rakshan/skills/search"),
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
