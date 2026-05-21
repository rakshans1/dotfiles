import fs from "fs";
import { KarabinerRules } from "./types";

// ──────── Hold/tap tunables ────────
const HOLD_TIME = 150; // letter holds (a/s/d/f, t)
const SPACE_HOLD_TIME = 80; // space hold (snappier sublayer)
const TAP_TIMEOUT = 400; // max ms to count as tap

const hrmParams = {
	"basic.to_if_held_down_threshold_milliseconds": HOLD_TIME,
	"basic.to_if_alone_timeout_milliseconds": TAP_TIMEOUT,
};

const spaceHoldParams = {
	"basic.to_if_held_down_threshold_milliseconds": SPACE_HOLD_TIME,
	"basic.to_if_alone_timeout_milliseconds": TAP_TIMEOUT,
};

// Condition: don't fire when space is held (so space-sublayer wins).
const notSpaceHeld = {
	type: "variable_if" as const,
	name: "spc_sublayer",
	value: 0,
};

const rules: KarabinerRules[] = [
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

	// Space-hold sys layer: tap = space; hold = spc_sublayer for app launches.
	{
		description: "Space-hold sys layer",
		manipulators: [
			{
				type: "basic",
				description: "Space -> spc_sublayer",
				from: { key_code: "spacebar", modifiers: { optional: ["any"] } },
				to_if_alone: [
					{ halt: true, key_code: "spacebar" },
					{ set_variable: { name: "spc_sublayer", value: 0 } },
				],
				to_if_held_down: [
					{ set_variable: { name: "spc_sublayer", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "spc_sublayer", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "spacebar" },
						{ set_variable: { name: "spc_sublayer", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: spaceHoldParams,
			},
			{
				type: "basic",
				description: "spc + g -> Chrome",
				from: { key_code: "g", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'Google Chrome.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
			{
				type: "basic",
				description: "spc + t -> Ghostty",
				from: { key_code: "t", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'Ghostty.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
			{
				type: "basic",
				description: "spc + b -> Arc",
				from: { key_code: "b", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'Arc.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
			{
				type: "basic",
				description: "spc + w -> WhatsApp",
				from: { key_code: "w", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'WhatsApp.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
			{
				type: "basic",
				description: "spc + e -> Sublime Text",
				from: { key_code: "e", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'Sublime Text.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
			{
				type: "basic",
				description: "spc + r -> Raycast",
				from: { key_code: "r", modifiers: { optional: ["any"] } },
				to: [{ shell_command: "/usr/bin/open -a 'Raycast.app'" }],
				conditions: [{ type: "variable_if", name: "spc_sublayer", value: 1 }],
			},
		],
	},

	// t-hold tmux switcher: tap = t; hold + j/k/l = tmux work/projects/personal
	{
		description: "t-hold tmux switcher",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "t", modifiers: { optional: ["any"] } },
				conditions: [notSpaceHeld],
				to_if_alone: [
					{ halt: true, key_code: "t" },
					{ set_variable: { name: "t_held", value: 0 } },
				],
				to_if_held_down: [
					{ set_variable: { name: "t_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "t_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [
						{ key_code: "t" },
						{ set_variable: { name: "t_held", value: 0 } },
					],
					to_if_invoked: [{ key_code: "vk_none" }],
				},
				parameters: hrmParams,
			},
			{
				type: "basic",
				description: "t + j -> tmux work",
				from: { key_code: "j", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux switch-client -t work",
					},
				],
				conditions: [{ type: "variable_if", name: "t_held", value: 1 }],
			},
			{
				type: "basic",
				description: "t + k -> tmux projects",
				from: { key_code: "k", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux switch-client -t projects",
					},
				],
				conditions: [{ type: "variable_if", name: "t_held", value: 1 }],
			},
			{
				type: "basic",
				description: "t + l -> tmux personal",
				from: { key_code: "l", modifiers: { optional: ["any"] } },
				to: [
					{
						shell_command:
							"/Users/rakshan/.nix-profile/bin/tmux switch-client -t personal",
					},
				],
				conditions: [{ type: "variable_if", name: "t_held", value: 1 }],
			},
		],
	},

	// Home-row mods (gregorias pattern with retroactive emit + debug variables).
	{
		description: "a-hold = Cmd",
		manipulators: [
			{
				type: "basic",
				from: { key_code: "a", modifiers: { optional: ["any"] } },
				conditions: [notSpaceHeld],
				to_if_alone: [{ halt: true, key_code: "a" }],
				to_if_held_down: [
					{ key_code: "left_command" },
					{ set_variable: { name: "a_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "a_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [{ key_code: "a" }],
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
				conditions: [notSpaceHeld],
				to_if_alone: [{ halt: true, key_code: "s" }],
				to_if_held_down: [
					{ key_code: "left_option" },
					{ set_variable: { name: "s_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "s_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [{ key_code: "s" }],
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
				conditions: [notSpaceHeld],
				to_if_alone: [{ halt: true, key_code: "d" }],
				to_if_held_down: [
					{ key_code: "left_control" },
					{ set_variable: { name: "d_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "d_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [{ key_code: "d" }],
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
				conditions: [notSpaceHeld],
				to_if_alone: [{ halt: true, key_code: "f" }],
				to_if_held_down: [
					{ key_code: "left_shift" },
					{ set_variable: { name: "f_held", value: 1 } },
				],
				to_after_key_up: [
					{ set_variable: { name: "f_held", value: 0 } },
				],
				to_delayed_action: {
					to_if_canceled: [{ key_code: "f" }],
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
