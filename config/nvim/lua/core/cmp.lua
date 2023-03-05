local M = {}
M.methods = {}

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
M.methods.has_words_before = has_words_before

---@deprecated use M.methods.has_words_before instead
M.methods.check_backspace = function()
  return not has_words_before()
end

local T = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

---wraps vim.fn.feedkeys while replacing key codes with escape codes
---Ex: feedkeys("<CR>", "n") becomes feedkeys("^M", "n")
---@param key string
---@param mode string
local function feedkeys(key, mode)
  vim.api.nvim_feedkeys(T(key), mode, true)
end

M.methods.feedkeys = feedkeys

M.methods.jumpable = require("core.luasnip").methods.jumpable

M.config = function()
  local status_cmp_ok, cmp = pcall(require, "cmp")
  if not status_cmp_ok then
    return
  end
  local status_luasnip_ok, luasnip = pcall(require, "luasnip")
  if not status_luasnip_ok then
    return
  end

  rvim.builtin.cmp = {
    active = true,
    on_config_done = nil,
    enabled = function()
      return rvim.builtin.cmp.active
    end,
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = false,
    },
    completion = {
      ---@usage The minimum length of a word to complete on.
      keyword_length = 1,
    },
    experimental = {
      ghost_text = false,
      native_menu = false,
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      max_width = 0,
      kind_icons = rvim.icons.kind,
      source_names = {
        nvim_lsp = "(LSP)",
        emoji = "(Emoji)",
        path = "(Path)",
        calc = "(Calc)",
        cmp_tabnine = "(Tabnine)",
        vsnip = "(Snippet)",
        luasnip = "(Snippet)",
        buffer = "(Buffer)",
        tmux = "(TMUX)",
        copilot = "(Copilot)",
        treesitter = "(TreeSitter)",
      },
      duplicates = {
        buffer = 1,
        path = 1,
        nvim_lsp = 0,
        luasnip = 1,
      },
      duplicates_default = 0,
      format = function(entry, vim_item)
        local max_width = rvim.builtin.cmp.formatting.max_width
        if max_width ~= 0 and #vim_item.abbr > max_width then
          vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. rvim.icons.ui.Ellipsis
        end
        if rvim.use_icons then
          vim_item.kind = rvim.builtin.cmp.formatting.kind_icons[vim_item.kind]

          if entry.source.name == "copilot" then
            vim_item.kind = rvim.icons.git.Octoface
            vim_item.kind_hl_group = "CmpItemKindCopilot"
          end

          if entry.source.name == "cmp_tabnine" then
            vim_item.kind = rvim.icons.misc.Robot
            vim_item.kind_hl_group = "CmpItemKindTabnine"
          end

          if entry.source.name == "crates" then
            vim_item.kind = rvim.icons.misc.Package
            vim_item.kind_hl_group = "CmpItemKindCrate"
          end

          if entry.source.name == "lab.quick_data" then
            vim_item.kind = rvim.icons.misc.CircuitBoard
            vim_item.kind_hl_group = "CmpItemKindConstant"
          end

          if entry.source.name == "emoji" then
            vim_item.kind = rvim.icons.misc.Smiley
            vim_item.kind_hl_group = "CmpItemKindEmoji"
          end
        end
        vim_item.menu = rvim.builtin.cmp.formatting.source_names[entry.source.name]
        vim_item.dup = rvim.builtin.cmp.formatting.duplicates[entry.source.name]
            or rvim.builtin.cmp.formatting.duplicates_default
        return vim_item
      end,
    },
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    sources = {
      {
        name = "copilot",
        -- keyword_length = 0,
        max_item_count = 3,
        trigger_characters = {
          {
            ".",
            ":",
            "(",
            "'",
            '"',
            "[",
            ",",
            "#",
            "*",
            "@",
            "|",
            "=",
            "-",
            "{",
            "/",
            "\\",
            "+",
            "?",
            " ",
            -- "\t",
            -- "\n",
          },
        },
      },
      { name = "nvim_lsp" },
      { name = "path" },
      { name = "luasnip" },
      { name = "cmp_tabnine" },
      { name = "nvim_lua" },
      { name = "buffer" },
      { name = "calc" },
      { name = "emoji" },
      { name = "treesitter" },
      { name = "crates" },
      { name = "tmux" },
    },
    mapping = {
      ["<C-k>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
      ["<C-j>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
      ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select }, { "i" }),
      ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select }, { "i" }),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-y>"] = cmp.mapping {
        i = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false },
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
          else
            fallback()
          end
        end,
      },
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif M.methods.jumpable(1) then
          luasnip.jump(1)
        elseif M.methods.has_words_before() then
          -- cmp.complete()
          fallback()
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, {
        "i",
        "s",
      }),

      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          local confirm_opts = vim.deepcopy(rvim.builtin.cmp.confirm_opts) -- avoid mutating the original opts below
          local is_insert_mode = function()
            return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
          end
          if is_insert_mode() then -- prevent overwriting brackets
            confirm_opts.behavior = cmp.ConfirmBehavior.Insert
          end
          if cmp.confirm(confirm_opts) then
            return
          end
        end

        if M.methods.jumpable(1) and luasnip.jump(1) then
          return
        end
        fallback()
      end),
    },
  }
end

function M.setup()
  local cmp = require "cmp"
  cmp.setup(rvim.builtin.cmp)

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "path" },
      { name = "cmdline" },
    },
  })
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    }
  })
  if rvim.builtin.cmp.on_config_done then
    rvim.builtin.cmp.on_config_done(cmp)
  end
end

return M
