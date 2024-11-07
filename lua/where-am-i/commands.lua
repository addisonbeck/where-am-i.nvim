---@class CommandsModule
local M = {}

---@return nil
M.please_tell_me = function (opts)
  -- Save the current window ID (to restore focus once the message
  -- showing the new file name is displayed)
  local current_win = vim.api.nvim_get_current_win()

  -- Get the file name of the newly focused buffer
  local file_path = vim.api.nvim_buf_get_name(0)
  local file_name = vim.fn.fnamemodify(file_path, ":t")

  if not file_name or #file_name == 0 then
    return
  end

  -- Infer a message width based on user configuration or the line length
  -- of the message
  local message_width = opts.size.width == "message_length" 
    and vim.fn.strwidth(file_name) 
    or opts.size.width;
  -- }}

  local message_height = opts.size.height == "message_height"
    and 1
    or opts.size.height

  -- Make sure there isn't already an open window for this function
  local buffer_name = opts.functionality.floating_buffer_name;

  -- Define a local variable to track the message buffer
  local floating_buf = nil

  -- If the file name window already exists: close it
  for _, existing_buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(existing_buf) == buffer_name then
    end
  end

  -- Make sure there isn't already an open window for this function
  -- Try to find any buffer that has a marker for our floating window
  local floating_buf = nil
  for _, existing_buf in ipairs(vim.api.nvim_list_bufs()) do
    local success, value = pcall(vim.api.nvim_buf_get_var, existing_buf, buffer_name)
    if success and value == 1 then
      pcall(vim.api.nvim_buf_delete, existing_buf, {force = true});
      break
    end
  end

  -- Create a buffer for displaying the file name of the newly
  -- focused main buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_var(buf, buffer_name, 1)

  -- TODO: implement opts.position {{
  local window_col_max = vim.api.nvim_win_get_width(0)
  local window_row_max = vim.api.nvim_win_get_height(0)
  local window_col_midpoint = window_col_max / 2
  local window_row_midpoint = window_row_max / 2

  local message_col_midpoint = message_width / 2
  local message_row_midpoint = message_height / 2

  -- Define positions in a table
  local positions = {
    N = { 
      row = 0, 
      col = window_col_midpoint - message_col_midpoint,
    },
    S = { 
      row = window_row_max, 
      col = window_col_midpoint - message_col_midpoint,
    },
    E = { 
      row = window_row_midpoint - message_row_midpoint, 
      col = window_col_max,
    },
    W = { 
      row = window_row_midpoint - message_row_midpoint, 
      col = 0,
    },
    NE = { 
      row = 0, 
      col = window_col_max,
    },
    NW = { 
      row = 0, 
      col = 0,
    },
    SE = { 
      row = window_row_max, 
      col = window_col_max,
    },
    SW = { 
      row = window_row_max, 
      col = 0,
    },
    center = { 
      row = window_row_midpoint - message_row_midpoint, 
      col = window_col_midpoint - message_col_midpoint,
    }
  }

  local pos = positions[opts.position.anchor] or positions.SE

  local win = vim.api.nvim_open_win(buf, true, {
    relative='win',
    
    row = pos.row;
    col = pos.col,
   
    height = opts.size.height == "message_height" and 1 or 0,

    -- TODO: implement opts.width {{
    width = message_width,
    -- }}
    
    focusable = false,
    border = opts.style.border,
    style = "minimal",
  })

  -- Set the content of the floating window
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { file_name })

  -- TODO: implement opts.highlights {{
  vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Normal')
  -- }}

  -- Restore focus to the original window after the floating window is created
  vim.api.nvim_set_current_win(current_win)

  -- Auto-close the floating window after a timeout
  if opts.functionality.hang_time ~= "infinite" then
    vim.defer_fn(function()
      pcall(vim.api.nvim_win_close, win, true)
      pcall(vim.api.nvim_buf_delete, buf, {force = true});
    end, opts.functionality.hang_time)
  end
end

---@return nil
M.next_buffer = function(opts)
  -- Move to the next buffer
  vim.cmd("bnext");
  M.please_tell_me(opts);
end

---@return nil
M.previous_buffer = function(opts)
  -- Move to the previous buffer
  vim.cmd("bprevious");
  M.please_tell_me(opts);
end

return M
