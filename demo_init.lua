-- Configure `where-am-i`

local default_opts = {
  -- optional features
  features = {
    keymaps = {
      enable = true,
    },

    user_commands = {
      enable = true,
    },
  },
  display = {
    -- Position of the floating window relative to the current window
    position = {
      -- The starting point for position evaluations.
      --
      -- Can be an abbreviated cardinal direction ("N", "NW", etc.) or "center"
      anchor = "SE",
    },

    size = {
      -- The height of the floating window in rows
      --
      -- Can be a number of rows or the string "message_length" for adaptive
      -- sizing.
      height = "message_height",

      -- The width of the floating buffer
      --
      -- Can be a number of columns or the string "message_length" for adaptive
      -- sizing.
      width = "message_length",
    },

    style = {
      -- The border style used by the float
      --
      -- Possible options are exactly the same as what you'd find for
      -- `:help nvim_open_win`'s border property
      --
      -- (eg. "single", "double", "rounded", "solid", "shadow", etc.)
      border = "single",

      -- Highlight group mappings.
      -- `key` = `where-am-i.nvim` highlight group
      -- `value` = A highlight group from your configuration to link to
      highlights = {
        hl_where_am_i_normal_float = "NormalFloat",
      },
    },

    content = {
      -- show and configure a line containing the file path of the file
      -- loaded to the currently active vim buffer
      file_path = {
        enable = true,
        -- possible_values = {
        --   "filename_only"
        --   "parent_dir_path"
        --   "present_working_dir_path"
        --   "system_path"
        -- }
        format = "filename_only",
      },
    },

    functionality = {
      -- The default command passed when running ":WhereAmI" with no arguments
      default_command = "please_tell_me",

      -- The buffer name given to the float. You probably don't care about this
      -- and can leave it set to the default
      floating_buffer_name = "where_am_i_float",

      -- The amount of time in milliseconds that the float should stay open
      -- before automatically closing.
      --
      -- Can be a number of milliseconds, or the string "infinite" to never auto
      -- close.
      hang_time = 1500,
    },
  },
}

require("where-am-i").setup(default_opts)

-- Set up a colorscheme
local theme = "dark"
local background_color = theme == "light" and "#f9f5d7" or "#1d2021"

require("gruvbox").setup({
  overrides = {
    Comment = { bold = true },
    Winbar = { bg = "NONE", bold = true, fg = 4 },
    WinbarNC = { bg = "NONE", bold = true, fg = 8 },
    Normal = { bg = background_color },
    NormalFloat = { bg = background_color },
  },
})

vim.cmd([[
  colorscheme gruvbox
  set laststatus=0
  hi! link StatusLine Normal
  hi! link StatusLineNC Normal
  set statusline=%{repeat('─',winwidth('.'))}
]])

vim.opt.background = theme

-- Hide the command line
vim.opt.cmdheight = 0

-- Telescope is helpful for debugging
require("telescope").setup({})
