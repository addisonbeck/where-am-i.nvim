vim.api.nvim_create_user_command(
  "WhereAmI", 
  (function (command_opts)
    require("where-am-i").load_command(unpack(command_opts.fargs));
  end), 
  { 
   complete = function(_, line)
      local l = vim.split(line, "%s+")
      local n = #l - 2

      if n == 0 then
        local commands = vim.tbl_keys(require "where-am-i.commands")
        -- TODO(clason): remove when dropping support for Nvim 0.9
        if vim.fn.has "nvim-0.11" == 1 then
          commands = vim.iter(commands):flatten():totable()
        else
          commands = vim.tbl_flatten(commands)
        end
        table.sort(commands)

        return vim.tbl_filter(function(val)
          return vim.startswith(val, l[2])
        end, commands)
      end
    end,
    nargs = "*",
  }
)
