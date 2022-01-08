local M = {}

local Log = require "core.log"

local function git_cmd(opts)
  local plenary_loaded, Job = pcall(require, "plenary.job")
  if not plenary_loaded then
    vim.cmd "packadd plenary.nvim"
  end

  opts = opts or {}
  opts.cwd = opts.cwd or get_rvim_base_dir()

  local stderr = {}
  local stdout, ret = Job
    :new({
      command = "git",
      args = opts.args,
      cwd = opts.cwd,
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    })
    :sync()

  if not vim.tbl_isempty(stderr) then
    Log:debug(stderr)
  end

  if not vim.tbl_isempty(stdout) then
    Log:debug(stdout)
  end

  return ret, stdout
end

local function safe_deep_fetch()
  local ret, result = git_cmd { args = { "rev-parse", "--is-shallow-repository" } }
  if ret ~= 0 then
    Log:error "Git fetch failed! Check the log for further information"
    return
  end
  -- git fetch --unshallow will cause an error on a a complete clone
  local fetch_mode = result[1] == "true" and "--unshallow" or "--all"
  ret = git_cmd { args = { "fetch", fetch_mode } }
  if ret ~= 0 then
    Log:error "Git fetch failed! Check the log for further information"
    return
  end
  return true
end

function M.generate_plugins_sha(output)
  local list = {}
  output = output or "commits.lua"

  local core_plugins = require "plugins"
  for _, plugin in pairs(core_plugins) do
    local name = plugin[1]:match "/(%S*)"
    local url = "https://github.com/" .. plugin[1]
    print("checking: " .. name .. ", at: " .. url)
    local retval, latest_sha = git_cmd { args = { "ls-remote", url, "origin", "HEAD" } }
    if retval == 0 then
      -- replace dashes, remove postfixes and use lowercase
      local normalize_name = (name:gsub("-", "_"):gsub("%.%S+", "")):lower()
      list[normalize_name] = latest_sha[1]:gsub("\tHEAD", "")
    end
  end
  require("utils").write_file(output, "local commit = " .. vim.inspect(list), "w")
end
return M
