local commands = require("where-am-i.commands")

---@class Opts
---@field features table Opt-in only, global features of the extension
---@field display table Configuration for a single `where-am-i.nvim` float
local default_opts = {
  features = {
    keymaps = {
      enable = false,
    },

    user_commands = {
      enable = false,
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

---@class WhereAmIModule
local M = {}

---@type Opts
local opts = default_opts

M.load_command = function(command)
  command = command or opts.display.functionality.default_command
  if commands[command] then
    commands[command](opts.display)
    return
  end
end

local attach_optional_keymaps = function()
  local optional_keymaps = {
    {
      key = "WAI",
      mode = { "n", "v" },
      options = {
        desc = "Show the current buffer",
        silent = true,
      },
      action = function()
        commands.please_tell_me(opts.display)
      end,
    },
    {
      key = "<Right>",
      mode = { "n", "v" },
      options = {
        desc = "Navigate one buffer down in the buffer list\n",
        silent = true,
      },
      action = function()
        commands.next_buffer(opts.display)
      end,
    },
    {
      key = "<Left>",
      mode = { "n", "v" },
      options = {
        desc = "Navigate one buffer up in the buffer list\n",
        silent = true,
      },
      action = function()
        commands.previous_buffer(opts.display)
      end,
    },
    {
      key = "<C-x>",
      mode = { "n", "i" },
      options = {
        desc = "Close the open buffer and show the filename of the newly focused one",
        silent = true,
      },
      action = function()
        commands.close_buffer(opts.display)
      end,
    },
  }
  for _, map in ipairs(optional_keymaps) do
    vim.keymap.set(map.mode, map.key, map.action, map.options)
  end
end

local attach_optional_user_commands = function()
  -- TODO: Add command descriptions
  vim.api.nvim_create_user_command("WhereAmI", function(command_opts)
    M.load_command(unpack(command_opts.fargs))
  end, {
    complete = function(_, line)
      local l = vim.split(line, "%s+")
      local n = #l - 2
      if n == 0 then
        local commands_keys = vim.tbl_keys(commands)
        local commands_list = vim.iter(commands_keys):flatten():totable()
        table.sort(commands_list)
        return vim.tbl_filter(function(val)
          return vim.startswith(val, l[2])
        end, commands_list)
      end
    end,
    nargs = "*",
  })
end

---@param user_opts Opts?
M.setup = function(user_opts)
  opts = vim.tbl_deep_extend("force", opts, user_opts or {})
  if opts.features.user_commands.enable then
    attach_optional_user_commands()
  end
  if opts.features.keymaps.enable then
    attach_optional_keymaps()
  end
end

return M
