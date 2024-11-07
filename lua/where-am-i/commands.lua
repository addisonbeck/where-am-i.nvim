---@class CommandsModule
local M = {}

-- Get the file path of the current buffer and format it to the specified
-- options
local resolve_file_path = function(opts)
  local system_file_path = vim.api.nvim_buf_get_name(0)
  local file_name = vim.fn.fnamemodify(system_file_path, ":t")
  local pwd = vim.fn.fnamemodify(system_file_path, ":~:.")

  if opts.content.file_path.format == "system_path" then
    return system_file_path
  end

  if opts.content.file_path.format == "present_working_dir_path" then
    return pwd
  end

  if opts.content.file_path.format == "parent_dir_path" then
    if file_name ~= pwd then
      return vim.fn.fnamemodify(system_file_path, ":h:t") .. "/" .. file_name
    end
  end

  return file_name
end

---@return nil
M.please_tell_me = function(opts)
  local current_win = vim.api.nvim_get_current_win()

  local lines = {}

  if opts.content.file_path.enable then
    local resolved_file_path = resolve_file_path(opts)
    if resolved_file_path then
      table.insert(lines, resolved_file_path)
    end
  end

  if #lines < 1 then
    return
  end

  local max_length = 0
  for _, str in ipairs(lines) do
    local len = #str
    if len > max_length then
      max_length = len
    end
  end
  local message_width = max_length
  if type(opts.size.width) == "number" then
    message_width = opts.size.width < message_width and opts.size.width
      or message_width
  end
  if message_width < 1 then
    return
  end

  local message_height = opts.size.height == "message_height" and #lines
    or opts.size.height

  local buffer_name = opts.functionality.floating_buffer_name

  for _, existing_buf in ipairs(vim.api.nvim_list_bufs()) do
    local success, value =
      pcall(vim.api.nvim_buf_get_var, existing_buf, buffer_name)
    if success and value == 1 then
      pcall(vim.api.nvim_buf_delete, existing_buf, { force = true })
      break
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_var(buf, buffer_name, 1)

  local window_col_max = vim.api.nvim_win_get_width(0)
  local window_row_max = vim.api.nvim_win_get_height(0)
  local window_col_midpoint = window_col_max / 2
  local window_row_midpoint = window_row_max / 2

  local message_col_midpoint = message_width / 2
  local message_row_midpoint = message_height / 2

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
    },
  }

  local pos = positions[opts.position.anchor] or positions.SE

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "win",

    row = pos.row,
    col = pos.col,

    height = opts.size.height == "message_height" and 1 or 0,

    width = message_width,

    focusable = false,
    border = opts.style.border,
    style = "minimal",
  })

  for i = 1, #lines do
    vim.api.nvim_buf_set_lines(buf, i - 1, 1, false, { lines[i] })
  end

  -- TODO: implement opts.highlights {{
  vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal")
  -- }}

  vim.api.nvim_set_current_win(current_win)

  if opts.functionality.hang_time ~= "infinite" then
    vim.defer_fn(function()
      pcall(vim.api.nvim_win_close, win, true)
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end, opts.functionality.hang_time)
  end
end

---@return nil
M.next_buffer = function(opts)
  vim.cmd("bnext")
  M.please_tell_me(opts)
end

---@return nil
M.previous_buffer = function(opts)
  vim.cmd("bprevious")
  M.please_tell_me(opts)
end

---@return nil
M.close_buffer = function(opts)
  local function is_only_buffer()
      local buffers = vim.tbl_filter(function(buf)
          return vim.bo[buf].buflisted
      end, vim.api.nvim_list_bufs())
      return #buffers == 1
  end
  if is_only_buffer() then
    vim.cmd("bd");
  else
    vim.cmd("bnext")
    vim.cmd("bd#")
  end
  M.please_tell_me(opts)
end

M.copy_file_name = function(opts)
  local value = resolve_file_path(opts)
  -- Get clipboard setting as a string
  local clipboard_setting = vim.opt.clipboard:get()
  vim.fn.setreg('"', value)
  if vim.tbl_contains(clipboard_setting, "unnamed") then
    vim.fn.setreg('*', value)
  end
  if vim.tbl_contains(clipboard_setting, "unnamedplus") then
    vim.fn.setreg('+', value)
  end
end

return M
