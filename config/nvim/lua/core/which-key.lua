local M = {}

M.config = function()
  rvim.builtin.which_key = {
    ---@usage disable which-key completely [not recommeded]
    active = true,
    on_config_done = nil,
    setup = {
      plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        presets = {
          operators = false, -- adds help for operators like d, y, ...
          motions = false, -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = true, -- default bindings on <c-w>
          nav = true, -- misc bindings to work with windows
          z = true, -- bindings for folds, spelling and others prefixed with z
          g = true, -- bindings for prefixed with g
        },
        spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints
      },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
      },
      window = {
        border = "none", -- none, single, double, shadow
        position = "bottom", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      },
      layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left"
      },
      hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
      show_help = true, -- show help message on the command line when the popup is visible
    },

    opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    vopts = {
      mode = "v", -- VISUAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    },
    -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
    -- see https://neovim.io/doc/user/map.html#:map-cmd
    vmappings = {
      ["/"] = { "<ESC><CMD>lua ___comment_gc(vim.fn.visualmode())<CR>", "Comment" },
    },
    mappings = {
      ["w"] = { "<cmd>w!<CR>", "Save" },
      ["q"] = { "<cmd>q!<CR>", "Quit" },
      ["/"] = { "<cmd>lua require('Comment').toggle()<CR>", "Comment" },
      ["c"] = { ":set hlsearch! hlsearch?<CR>", "Close Buffer" },
      ["f"] = { "<cmd>Telescope find_files<CR>", "Find File" },
      ["o"] = { "<cmd>Telescope lsp_document_symbols<CR>", "Document Symbol" },
      ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
      b = {
        name = "Buffers",
        j = { "<cmd>BufferPick<cr>", "Jump" },
        f = { "<cmd>Telescope buffers<cr>", "Find" },
        b = { "<cmd>b#<cr>", "Previous" },
        w = { "<cmd>BufferWipeout<cr>", "Wipeout" },
        e = {
          "<cmd>BufferCloseAllButCurrent<cr>",
          "Close all but current",
        },
        h = { "<cmd>BufferCloseBuffersLeft<cr>", "Close all to the left" },
        l = {
          "<cmd>BufferCloseBuffersRight<cr>",
          "Close all to the right",
        },
        D = {
          "<cmd>BufferOrderByDirectory<cr>",
          "Sort by directory",
        },
        L = {
          "<cmd>BufferOrderByLanguage<cr>",
          "Sort by language",
        },
      },
      P = {
        name = "Packer",
        c = { "<cmd>PackerCompile<cr>", "Compile" },
        i = { "<cmd>PackerInstall<cr>", "Install" },
        r = { "<cmd>lua require('utils').reload_lv_config()<cr>", "Reload" },
        s = { "<cmd>PackerSync<cr>", "Sync" },
        S = { "<cmd>PackerStatus<cr>", "Status" },
        u = { "<cmd>PackerUpdate<cr>", "Update" },
      },
      t = {
        name = "Diagnostics",
        t = { "<cmd>TroubleToggle<cr>", "trouble" },
        w = { "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", "workspace" },
        d = { "<cmd>TroubleToggle lsp_document_diagnostics<cr>", "document" },
        q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
        l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
        r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
      },
      g = {
        name = "Git",
        j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
        k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
        l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
        p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
        r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
        R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
        s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
        u = {
          "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
          "Undo Stage Hunk",
        },
        o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        C = {
          "<cmd>Telescope git_bcommits<cr>",
          "Checkout commit(for current file)",
        },
        d = {
          "<cmd>Gitsigns diffthis HEAD<cr>",
          "Git Diff",
        },
      },

      l = {
        name = "LSP",
        a = { "<cmd>lua require('core.telescope').code_actions()<cr>", "Code Action" },
        d = {
          "<cmd>Telescope lsp_document_diagnostics<cr>",
          "Document Diagnostics",
        },
        w = {
          "<cmd>Telescope lsp_workspace_diagnostics<cr>",
          "Workspace Diagnostics",
        },
        f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
        i = { "<cmd>LspInfo<cr>", "Info" },
        I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
        j = {
          "<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts = {border = rvim.lsp.popup_border}})<cr>",
          "Next Diagnostic",
        },
        k = {
          "<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts = {border = rvim.lsp.popup_border}})<cr>",
          "Prev Diagnostic",
        },
        l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
        p = {
          name = "Peek",
          d = { "<cmd>lua require('lsp.peek').Peek('definition')<cr>", "Definition" },
          t = { "<cmd>lua require('lsp.peek').Peek('typeDefinition')<cr>", "Type Definition" },
          i = { "<cmd>lua require('lsp.peek').Peek('implementation')<cr>", "Implementation" },
        },
        q = { "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", "Quickfix" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        S = {
          "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
          "Workspace Symbols",
        },
      },
      L = {
        name = "+NeoVim",
        i = {
          "<cmd>lua require('core.info').toggle_popup(vim.bo.filetype)<cr>",
          "Toggle NeoVim Info",
        },
        l = {
          name = "+logs",
          d = {
            "<cmd>lua require('core.terminal').toggle_log_view(require('core.log').get_path())<cr>",
            "view default log",
          },
          D = { "<cmd>lua vim.fn.execute('edit ' .. require('core.log').get_path())<cr>", "Open the default logfile" },
          l = { "<cmd>lua require('core.terminal').toggle_log_view(vim.lsp.get_log_path())<cr>", "view lsp log" },
          L = { "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>", "Open the LSP logfile" },
          n = {
            "<cmd>lua require('core.terminal').toggle_log_view(os.getenv('NVIM_LOG_FILE'))<cr>",
            "view neovim log",
          },
          N = { "<cmd>edit $NVIM_LOG_FILE<cr>", "Open the Neovim logfile" },
          p = {
            "<cmd>lua require('core.terminal').toggle_log_view('packer.nvim')<cr>",
            "view packer log",
          },
          P = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<cr>", "Open the Packer logfile" },
        },
        r = { "<cmd>lua require('utils').reload_lv_config()<cr>", "Reload configurations" },
      },
      ["p"] = { "<cmd>Telescope live_grep<cr>", "Text" },
      s = {
        name = "Search",
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
        f = { "<cmd>Telescope find_files<cr>", "Find File" },
        h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
        R = { "<cmd>Telescope registers<cr>", "Registers" },
        t = { "<cmd>Telescope live_grep<cr>", "Text" },
        k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
        C = { "<cmd>Telescope commands<cr>", "Commands" },
        p = {
          "<cmd>lua require('telescope.builtin.internal').colorscheme({enable_preview = true})<cr>",
          "Colorscheme with Preview",
        },
        g = {
          name = "+Git",
          p = { "<cmd>Telescope gh pull_request<cr>", "Pull Requests" },
          i = { "<cmd>Telescope gh issues<cr>", "Issues" },
          r = { "<cmd>Telescope gh run<cr>", "Run" },
        }
      },
      T = {
        name = "Treesitter",
        i = { ":TSConfigInfo<cr>", "Info" },
      },
    },
  }
end

M.setup = function()
  local which_key = require "which-key"

  which_key.setup(rvim.builtin.which_key.setup)

  local opts = rvim.builtin.which_key.opts
  local vopts = rvim.builtin.which_key.vopts

  local mappings = rvim.builtin.which_key.mappings
  local vmappings = rvim.builtin.which_key.vmappings

  which_key.register(mappings, opts)
  which_key.register(vmappings, vopts)

  if rvim.builtin.which_key.on_config_done then
    rvim.builtin.which_key.on_config_done(which_key)
  end
end

return M
