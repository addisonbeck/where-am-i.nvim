# 🙋 `where-am-i.nvim`

A Neovim plugin designed to keep track of where the heck you are right now.

> [!important]
> This plugin is in early development and has not had an "official" release.
> Use at your own discretion for the time being! APIs may change at any time
> without documentation.

![demo video](.github/assets/demo.gif)

## ✨ Features

By default `where-am-i.nvim` only exposes some lua functions for hooking in
to from your own user commands, auto commands, keymaps, etc. That said: there is
also a works-out-of-the-box experience that includes a combination of user
commands, auto commands, and keymaps. 

### User Commands

If the `user_commands` feature is enabled `where-am-i.nvim` exposes a set of
useful user commands. 

| Command | Subcommand | Description |
| ------- | ---------- | ----------- |
| `:WhereAmI` | | The root command |
| | `please_tell_me` | Shows an ephemeral floating window displaying the current filename |
| | `next_buffer`| Runs `:bnext` and displays the name of the newly focused file |
| | `previous_buffer` | Runs `:previous` and displays the name of the newly focused file |
| | `close_buffer` | Runs `:bd` and displays the name of the newly focused file |
| | `copy_file_name` | Yanks the file name of the currently open buffer |

### Keymaps

If the `keymaps` feature is enabled `where-am-i.nvim` adds a set of
useful normal, visual, and insert mode keymaps. 

| Command | Description |
| ---------- | ----------- |
| `WAI` | Shows an ephemeral floating window displaying the current filename |
| `<Right>`| Runs `:bnext` and displays the name of the newly focused file |
| `<Left>` | Runs `:bprevious` and displays the name of the newly focused file |
| `<C-x>` | Runs `:bd` and displays the name of the newly focused file |

## 📦 Installation

Install the plugin with your package manager.

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "addisonbeck/where-am-i.nvim",
  opts = {
    -- {optional_configuration_here}
    -- See the configuration section below for available options.
  },
}
```

### [nix](https://github.com/NixOS/nix)

Users of the nix package manager can test drive `where-am-i.nvim` without
installing it using this nix command:

```sh
nix run github:addisonbeck/where-am-i.nvim
```

The `init.lua` used by the instance of Neovim that opens can be found in
[`demo_init.lua`](https://github.com/addisonbeck/where-am-i.nvim/blob/main/demo_init.lua).

To add the plugin to your nix-based Neovim configuration permanently add the
following to your personal `flake.nix`:

```nix
inputs = {
  # ... Other inputs
  where-am-i-nvim.url = "github:addisonbeck/where-am-i.nvim/main";
  where-am-i-nvim.inputs.nixpkgs.follows = "nixpkgs";
  # ... Other inputs
};
```

From here you'd import the plugin alongside wherever else you declare neovim
plugins in your configuration. This is different for different distributions,
so check with yours, but it will likely look something like this:

```nix
# ... Other config
packages.main = {
  start = [
    inputs.where-am-i-nvim.packages.${pkgs.system}.default
  ];
};
# ... Other config
```

## 🎛️ Configuration

Here's the same `lazy.nvim` installation explicitly setting all of the default options:

```lua
{
  "addisonbeck/where-am-i.nvim",
  opts = {
    -- optional features
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
}
```

## 👾 Development

A nix flake & direnv based development environment is supported out of the
box. Just clone the repository, run `direnv allow` in the project root, and
then you can use the `just` commands in the `justfile` to locally test
any changes.

From the project root with the nix flake's `devShell` loaded run `just run` and
you will end up inside a Neovim instance with any local changes you have made
to the plugin source applied and ready to test.
