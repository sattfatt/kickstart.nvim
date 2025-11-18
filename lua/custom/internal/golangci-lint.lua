-- golangci_lint.lua
-- Custom golangci-lint diagnostic plugin for Neovim
-- Designed for golangci-lint v2

local M = {}

M.namespace = vim.api.nvim_create_namespace 'golangci_lint'

-- Configuration options
M.config = {
  use_quickfix = false, -- Set to true to auto-populate quickfix list on lint
}

-- Map golangci-lint severity to vim.diagnostic.severity
local severity_map = {
  error = vim.diagnostic.severity.ERROR,
  warning = vim.diagnostic.severity.WARN,
  info = vim.diagnostic.severity.INFO,
  hint = vim.diagnostic.severity.HINT,
}

-- Map severity to quickfix type
local qf_type_map = {
  error = 'E',
  warning = 'W',
  info = 'I',
  hint = 'N',
}

local function parse_json_output(output)
  local ok, data = pcall(vim.json.decode, output)
  if not ok or not data then
    return nil
  end
  return data
end

local function get_diagnostics_for_buffer(data, bufnr)
  local diagnostics = {}
  local bufname = vim.api.nvim_buf_get_name(bufnr)

  if not data.Issues then
    return diagnostics
  end

  for _, issue in ipairs(data.Issues) do
    local pos = issue.Pos or {}
    local filepath = pos.Filename or ''

    -- Match against buffer (handle relative/absolute paths)
    --if filepath ~= '' and (bufname:match(filepath .. '$') or filepath == bufname) then
    if filepath ~= '' and (bufname:match(filepath .. '$') or filepath == bufname) then
      local lnum = (pos.Line or 1) - 1 -- Convert to 0-indexed
      local col = (pos.Column or 1) - 1
      local end_lnum = lnum
      local end_col = col

      -- Use range if available
      if issue.SourceLines and #issue.SourceLines > 0 then
        end_lnum = lnum + #issue.SourceLines - 1
      end

      local severity = severity_map[issue.Severity] or vim.diagnostic.severity.WARN

      table.insert(diagnostics, {
        lnum = lnum,
        col = col,
        end_lnum = end_lnum,
        end_col = end_col,
        message = issue.Text or 'Unknown issue',
        source = 'golangci-lint',
        code = issue.FromLinter,
        severity = severity,
      })
    end
  end

  return diagnostics
end

local function get_quickfix_list(data)
  local qf_list = {}

  if not data.Issues then
    return qf_list
  end

  for _, issue in ipairs(data.Issues) do
    local pos = issue.Pos or {}
    local filepath = pos.Filename or ''

    if filepath ~= '' then
      local lnum = pos.Line or 1 -- Keep 1-indexed for quickfix
      local col = pos.Column or 1

      local qf_type = qf_type_map[issue.Severity] or 'W'
      local linter = issue.FromLinter or 'golangci-lint'

      table.insert(qf_list, {
        filename = filepath,
        lnum = lnum,
        col = col,
        text = string.format('[%s] %s', linter, issue.Text or 'Unknown issue'),
        type = qf_type,
      })
    end
  end

  return qf_list
end

local function scope(bufnr, root)
  if root then
    local go_mod = vim.fs.find('go.mod', {
      path = dir,
      upward = true,
      type = 'file',
    })[1]

    if go_mod then
      return vim.fs.dirname(go_mod)
    end
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local dir = vim.fn.fnamemodify(bufname, ':h')
  return dir
end

function M.lint(bufnr, root, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or {}

  if vim.bo[bufnr].filetype ~= 'go' then
    return
  end

  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == '' then
    return
  end

  dir = scope(bufnr, root)

  local cmd = {
    'golangci-lint',
    'run',
    '--output.json.path=stdout',
    '--output.text.path=',
    '--issues-exit-code=0',
    '--show-stats=false',
    '--path-mode=abs',
  }

  -- if not root then
  --   table.insert(cmd, '--new-from-rev=origin/main')
  -- end

  -- Create animated loading notification
  local notif = vim.notify('Running golangci-lint...', vim.log.levels.INFO, {
    title = 'golangci-lint',
    animate = true,
  })

  vim.system(cmd, { text = true, cwd = dir }, function(obj)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      local diagnostics = {}
      local data = nil

      if obj.stdout and obj.stdout ~= '' then
        data = parse_json_output(obj.stdout)
        if data then
          diagnostics = get_diagnostics_for_buffer(data, bufnr)
        end
      end

      -- Close the loading notification
      if notif and type(notif) == 'table' and notif.close then
        notif:close()
      end

      vim.diagnostic.set(M.namespace, bufnr, diagnostics)

      -- Show completion notification
      local issue_count = data and data.Issues and #data.Issues or 0
      vim.notify(string.format('Found %d issue(s)', issue_count), vim.log.levels.INFO, {
        title = 'golangci-lint',
      })

      -- Populate quickfix list if enabled or explicitly requested
      if (M.config.use_quickfix or opts.use_quickfix) and data then
        local qf_list = get_quickfix_list(data)
        vim.fn.setqflist(qf_list, 'r') -- 'r' replaces the list
        vim.fn.setqflist({}, 'a', { title = 'golangci-lint' })
        vim.cmd 'copen' -- Auto-open quickfix list
      end
    end)
  end)
end

function M.clear(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.diagnostic.reset(M.namespace, bufnr)
end

function M.setup(opts)
  opts = opts or {}

  -- Set config options
  if opts.use_quickfix ~= nil then
    M.config.use_quickfix = opts.use_quickfix
  end

  local group = vim.api.nvim_create_augroup('GolangciLint', { clear = true })

  local events = opts.events or { 'BufWritePost' }

  vim.api.nvim_create_autocmd(events, {
    group = group,
    pattern = '*.go',
    callback = function(args)
      M.lint(args.buf, false)
    end,
  })

  -- Create user commands
  vim.api.nvim_create_user_command('GolangciLint', function()
    vim.notify 'running lint relative to origin/main'
    M.lint(nil, false)
  end, { desc = 'Run golangci-lint on current buffer' })

  vim.api.nvim_create_user_command('GolangciLintAll', function()
    vim.notify 'running lint from module root relative to current buffer'
    M.lint(nil, true)
  end, { desc = 'Run golangci-lint on current buffer' })

  vim.api.nvim_create_user_command('GolangciLintQuickfix', function()
    vim.notify 'running lint and populating quickfix list'
    M.lint(nil, false, { use_quickfix = true })
  end, { desc = 'Run golangci-lint and populate quickfix list' })

  vim.api.nvim_create_user_command('GolangciLintAllQuickfix', function()
    vim.notify 'running lint from module root and populating quickfix list'
    M.lint(nil, true, { use_quickfix = true })
  end, { desc = 'Run golangci-lint on module and populate quickfix list' })

  vim.api.nvim_create_user_command('GolangciLintClear', function()
    M.clear()
  end, { desc = 'Clear golangci-lint diagnostics' })
end

return M
