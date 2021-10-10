local M = {}

local utils = require "utils"

function M.config()
  -- Define this minimal config so that it's available if telescope is not yet available.
  rvim.builtin.telescope = {
    ---@usage disable telescope completely [not recommeded]
    active = true,
    on_config_done = nil,
  }

  local status_ok, actions = pcall(require, "telescope.actions")
  if not status_ok then
    return
  end

  rvim.builtin.telescope = vim.tbl_extend("force", rvim.builtin.telescope, {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      layout_config = {
        width = 0.75,
        prompt_position = "bottom",
        preview_cutoff = 120,
        horizontal = { mirror = false },
        vertical = { mirror = false },
      },
      file_sorter = require("telescope.sorters").get_fzy_sorter,
      file_ignore_patterns = {},
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { shorten = 5 },
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

      -- Developer configurations: Not meant for general override
      -- buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      mappings = {
        i = {
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          ["<C-c>"] = actions.close,
          ["<C-n>"] = actions.cycle_history_next,
          ["<C-p>"] = actions.cycle_history_prev,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          ["<CR>"] = actions.select_default + actions.center,
          -- To disable a keymap, put [map] = false
          -- So, to not map "<C-n>", just put
          -- ["<c-t>"] = trouble.open_with_trouble,
          -- ["<c-x>"] = false,
          -- ["<esc>"] = actions.close,
          -- Otherwise, just set the mapping to the function that you want it to be.
          -- ["<C-i>"] = actions.select_horizontal,
          -- Add up multiple actions
          -- You can perform as many actions in a row as you like
          -- ["<CR>"] = actions.select_default + actions.center + my_cool_custom_action,
        },
        n = {
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
          -- ["<c-t>"] = trouble.open_with_trouble,
          -- ["<C-i>"] = my_cool_custom_action,
        },
      },
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case"
      }
    },
  })
end

function M.code_actions()
  local opts = {
    winblend = 15,
    layout_config = {
      prompt_position = "top",
      width = 80,
      height = 12,
    },
    borderchars = {
      prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
    border = {},
    previewer = false,
    shorten_path = false,
  }
  require("telescope.builtin").lsp_code_actions(require("telescope.themes").get_dropdown(opts))
end

function M.setup()
  local telescope = require "telescope"
  telescope.setup(rvim.builtin.telescope)
  telescope.load_extension('fzf')
  telescope.load_extension('gh')
end

return M
