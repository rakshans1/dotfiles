-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/rakshanshetty/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/rakshanshetty/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/rakshanshetty/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/rakshanshetty/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/rakshanshetty/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["Dockerfile.vim"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim"
  },
  ["auto-pairs"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/auto-pairs"
  },
  ["coc.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/coc.nvim"
  },
  ["codi.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/codi.vim"
  },
  ["diffview.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/diffview.nvim"
  },
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/editorconfig-vim"
  },
  ["emmet-vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/emmet-vim"
  },
  ["fugitive-gitlab.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/fugitive-gitlab.vim"
  },
  fzf = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/fzf.vim"
  },
  ["goyo.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/goyo.vim"
  },
  ["iceberg.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/iceberg.vim"
  },
  ["limelight.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/limelight.vim"
  },
  ["markdown-preview.nvim"] = {
    commands = { "MarkdownPreview" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/markdown-preview.nvim"
  },
  nerdcommenter = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nerdcommenter"
  },
  nerdtree = {
    commands = { "NERDTreeToggle", "NERDTreeFind" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/nerdtree"
  },
  ["nerdtree-git-plugin"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nerdtree-git-plugin"
  },
  ["ngswitcher.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/ngswitcher.vim"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["nvim-treesitter-textobjects"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textobjects"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["splitjoin.vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/splitjoin.vim"
  },
  tabular = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/tabular"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["typewriter-vim"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/typewriter-vim"
  },
  undotree = {
    commands = { "UndotreeToggle" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/undotree"
  },
  ["vim-airline"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-airline"
  },
  ["vim-css3-syntax"] = {
    loaded = false,
    needs_bufread = false,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vim-css3-syntax"
  },
  ["vim-dadbod"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-dadbod"
  },
  ["vim-devicons"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-devicons"
  },
  ["vim-easy-align"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-easymotion"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-easymotion"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-gitgutter"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-gitgutter"
  },
  ["vim-markdown"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-markdown"
  },
  ["vim-nerdtree-syntax-highlight"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-nerdtree-syntax-highlight"
  },
  ["vim-node"] = {
    loaded = false,
    needs_bufread = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vim-node"
  },
  ["vim-peekaboo"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-peekaboo"
  },
  ["vim-reason-plus"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-reason-plus"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-repeat"
  },
  ["vim-rescript"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-rescript"
  },
  ["vim-rhubarb"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-rhubarb"
  },
  ["vim-startify"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-startify"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-test"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-test"
  },
  ["vim-wakatime"] = {
    loaded = true,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/start/vim-wakatime"
  },
  ["vista.vim"] = {
    commands = { "Vista" },
    loaded = false,
    needs_bufread = false,
    path = "/Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vista.vim"
  }
}

time([[Defining packer_plugins]], false)

-- Command lazy-loads
time([[Defining lazy-load commands]], true)
vim.cmd [[command! -nargs=* -range -bang -complete=file NERDTreeToggle lua require("packer.load")({'nerdtree'}, { cmd = "NERDTreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file NERDTreeFind lua require("packer.load")({'nerdtree'}, { cmd = "NERDTreeFind", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file Vista lua require("packer.load")({'vista.vim'}, { cmd = "Vista", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file UndotreeToggle lua require("packer.load")({'undotree'}, { cmd = "UndotreeToggle", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
vim.cmd [[command! -nargs=* -range -bang -complete=file MarkdownPreview lua require("packer.load")({'markdown-preview.nvim'}, { cmd = "MarkdownPreview", l1 = <line1>, l2 = <line2>, bang = <q-bang>, args = <q-args> }, _G.packer_plugins)]]
time([[Defining lazy-load commands]], false)

vim.cmd [[augroup packer_load_aucmds]]
vim.cmd [[au!]]
  -- Filetype lazy-loads
time([[Defining lazy-load filetype autocommands]], true)
vim.cmd [[au FileType css ++once lua require("packer.load")({'vim-css3-syntax'}, { ft = "css" }, _G.packer_plugins)]]
vim.cmd [[au FileType Dockerfile ++once lua require("packer.load")({'Dockerfile.vim'}, { ft = "Dockerfile" }, _G.packer_plugins)]]
vim.cmd [[au FileType javascript ++once lua require("packer.load")({'vim-node'}, { ft = "javascript" }, _G.packer_plugins)]]
time([[Defining lazy-load filetype autocommands]], false)
vim.cmd("augroup END")
vim.cmd [[augroup filetypedetect]]
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vim-node/ftdetect/node.vim]], true)
vim.cmd [[source /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vim-node/ftdetect/node.vim]]
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/vim-node/ftdetect/node.vim]], false)
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/docker-compose.vim]], true)
vim.cmd [[source /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/docker-compose.vim]]
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/docker-compose.vim]], false)
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/Dockerfile.vim]], true)
vim.cmd [[source /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/Dockerfile.vim]]
time([[Sourcing ftdetect script at: /Users/rakshanshetty/.local/share/nvim/site/pack/packer/opt/Dockerfile.vim/ftdetect/Dockerfile.vim]], false)
vim.cmd("augroup END")
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
