local M = {}

local join_paths = require("utils").join_paths

function M.config()
  rvim.builtin.mason = {
    ui = {
      border = "rounded",
      keymaps = {
        toggle_package_expand = "<CR>",
        install_package = "i",
        update_package = "u",
        check_package_version = "c",
        update_all_packages = "U",
        check_outdated_packages = "C",
        uninstall_package = "X",
        cancel_installation = "<C-c>",
        apply_language_filter = "<C-f>",
      },
    },
    install_root_dir = join_paths(vim.fn.stdpath "data", "mason"),
    PATH = "skip",
    pip = {
      install_args = {},
    },
    log_level = vim.log.levels.INFO,
    max_concurrent_installers = 4,

    github = {
      -- The template URL to use when downloading assets from GitHub.
      -- The placeholders are the following (in order):
      -- 1. The repository (e.g. "rust-lang/rust-analyzer")
      -- 2. The release version (e.g. "v0.3.0")
      -- 3. The asset name (e.g. "rust-analyzer-v0.3.0-x86_64-unknown-linux-gnu.tar.gz")
      download_url_template = "https://github.com/%s/releases/download/%s/%s",
    },
  }
end

function M.get_prefix()
  local default_prefix = join_paths(vim.fn.stdpath "data", "mason")
  return vim.tbl_get(rvim.builtin, "mason", "install_root_dir") or default_prefix
end

---@param append boolean|nil whether to append to prepend to PATH
local function add_to_path(append)
  local p = join_paths(M.get_prefix(), "bin")
  if vim.env.PATH:match(p) then
    return
  end
  local string_separator = vim.loop.os_uname().version:match "Windows" and ";" or ":"
  if append then
    vim.env.PATH = vim.env.PATH .. string_separator .. p
  else
    vim.env.PATH = p .. string_separator .. vim.env.PATH
  end
end

function M.bootstrap()
  add_to_path()
end

function M.setup()
  local status_ok, mason = pcall(require, "mason")
  if not status_ok then
    return
  end

  add_to_path(rvim.builtin.mason.PATH == "append")

  mason.setup(rvim.builtin.mason)
end

return M
