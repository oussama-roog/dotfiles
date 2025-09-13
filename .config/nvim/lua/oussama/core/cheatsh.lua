local M = {}

-- Get current buffer's filetype/language
local function get_current_filetype()
  local filetype = vim.bo.filetype
  if filetype == "" then
    -- Fallback to file extension if filetype is empty
    local filename = vim.api.nvim_buf_get_name(0)
    local ext = filename:match("%.([^%.]+)$")
    return ext or "bash"
  end

  -- Map some common filetypes to cheat.sh languages
  local filetype_map = {
    javascript = "js",
    typescript = "js",
    python = "python",
    lua = "lua",
    go = "go",
    rust = "rust",
    cpp = "cpp",
    c = "c",
    java = "java",
    php = "php",
    ruby = "ruby",
    bash = "bash",
    zsh = "bash",
    sh = "bash",
    vim = "vim",
  }

  return filetype_map[filetype] or filetype
end

-- Query cheat.sh service
local function query_cheatsh(lang, query, callback)
  -- Format the URL - use language context if available
  -- Use ?T for plain text (removes ANSI colors but keeps comments)
  local url
  if lang and lang ~= "" then
    url = string.format("https://cht.sh/%s/%s?T", lang, query:gsub(" ", "+"))
  else
    url = string.format("https://cht.sh/%s?T", query:gsub(" ", "+"))
  end

  -- Use curl to fetch the result
  local cmd = {"curl", "-s", "--max-time", "10", url}

  vim.system(cmd, {text = true}, function(result)
    vim.schedule(function()
      if result.code == 0 and result.stdout then
        local content = result.stdout
        if content:match("^%s*$") or content:match("Unknown topic") then
          callback("No results found for: " .. query)
        else
          callback(content)
        end
      else
        callback("Error fetching from cheat.sh: " .. (result.stderr or "Unknown error"))
      end
    end)
  end)
end

-- Show results in a floating window
local function show_result_window(content, lang, query)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Calculate window size (80% of screen)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Set buffer content
  local lines = vim.split(content, "\n")
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = string.format(" cheat.sh: %s/%s ", lang or "general", query),
    title_pos = 'center',
  })

  -- Set buffer options
  vim.bo[buf].filetype = lang or 'text'
  vim.bo[buf].readonly = true
  vim.bo[buf].modifiable = false

  -- Set window options
  vim.wo[win].wrap = false
  vim.wo[win].number = true
  vim.wo[win].relativenumber = false

  -- Key mappings for the result window
  local keymaps = {
    {'n', 'q', '<Cmd>close<CR>', 'Close window'},
    {'n', '<Esc>', '<Cmd>close<CR>', 'Close window'},
    {'n', 'r', function() M.open_cheatsh_picker() end, 'New search'},
    {'n', 'y', function()
      local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local text = table.concat(all_lines, "\n")
      vim.fn.setreg('+', text)
      vim.notify("Copied to clipboard!", vim.log.levels.INFO)
    end, 'Copy all to clipboard'},
  }

  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(keymap[1], keymap[2], keymap[3], {
      buffer = buf,
      silent = true,
      desc = keymap[4]
    })
  end

  -- Show help message
  vim.notify("Use 'q' to close, 'r' for new search, 'y' to copy", vim.log.levels.INFO)
end

-- Main function to open the cheat.sh picker
function M.open_cheatsh_picker()
  local lang = get_current_filetype()

  -- Check if snacks.nvim is available
  local ok, Snacks = pcall(require, 'snacks')
  if not ok then
    vim.notify("snacks.nvim is required for this plugin", vim.log.levels.ERROR)
    return
  end

  -- Create input prompt for query
  vim.ui.input({
    prompt = string.format("🔍 cheat.sh query (language: %s): ", lang or "auto"),
  }, function(value)
    if value and value ~= "" then
      vim.notify(string.format("Searching cheat.sh for: %s", value), vim.log.levels.INFO)
      query_cheatsh(lang, value, function(result)
        show_result_window(result, lang, value)
      end)
    end
  end)
end

-- Setup function for lazy loading
function M.setup(opts)
  opts = opts or {}

  -- Set up the keymap
  local keymap = opts.keymap or "<Leader>cs"
  vim.keymap.set('n', keymap, M.open_cheatsh_picker, {
    desc = "Open cheat.sh query picker",
    silent = true
  })

  -- Create user command
  vim.api.nvim_create_user_command('CheatSh', function(cmd_opts)
    if cmd_opts.args ~= "" then
      local lang = get_current_filetype()
      query_cheatsh(lang, cmd_opts.args, function(result)
        show_result_window(result, lang, cmd_opts.args)
      end)
    else
      M.open_cheatsh_picker()
    end
  end, {
    nargs = '*',
    desc = 'Query cheat.sh directly or open picker'
  })
end

return M