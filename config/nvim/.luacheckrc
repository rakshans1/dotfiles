-- vim: ft=lua tw=80

stds.nvim = {
  globals = {
    "rvim",
    vim = { fields = { "g" } },
    "TERMINAL",
    "USER",
    "C",
    "Config",
    "WORKSPACE_PATH",
    "USER_CONFIG_PATH",
    os = { fields = { "capture" } },
  },
  read_globals = {
    "jit",
    "os",
    "vim",
    "join_paths",
    "get_runtime_dir",
    "get_config_dir",
    "get_cache_dir",
    "get_version",
    -- vim = { fields = { "cmd", "api", "fn", "o" } },
  },
}
std = "lua51+nvim"

files["tests/*_spec.lua"].std = "lua51+nvim+busted"

-- Don't report unused self arguments of methods.
self = false

-- Rerun tests only if their modification time changed.
cache = true

ignore = {
  "631", -- max_line_length
  "212/_.*", -- unused argument, for vars with "_" prefix
}
