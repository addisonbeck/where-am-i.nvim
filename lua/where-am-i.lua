local commands = require "where-am-i.commands"

---@class Opts
---@field position string The position of the prompt
---@field height int The height of the prompt
local default_opts = {
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
}

---@class WhereAmIModule
local M = {}

---@type Opts
local opts = default_opts

---@param args Opts?
M.setup = function(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})
end

M.load_command = function(command)
  command = command or opts.functionality.default_command
  if commands[command] then
    commands[command](opts)
    return
  end
end

return M
