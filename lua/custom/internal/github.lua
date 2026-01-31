-- GitHub PR Comment Viewer Plugin
-- Displays PR comments as virtual text in the current buffer

local M = {}
local api = vim.api
local fn = vim.fn

-- Plugin state
local state = {
  enabled = false,
  comments = {},
  namespace = api.nvim_create_namespace 'github_pr_comments',
  pr_number = nil,
  repo_owner = nil,
  repo_name = nil,
}

-- Highlight groups for styling
local function setup_highlights()
  api.nvim_set_hl(0, 'GithubPRCommentAuthor', { fg = '#58a6ff', bold = true })
  api.nvim_set_hl(0, 'GithubPRCommentText', { fg = '#8b949e', italic = true })
  api.nvim_set_hl(0, 'GithubPRCommentLine', { fg = '#f85149' })
  api.nvim_set_hl(0, 'GithubPRCommentDate', { fg = '#6e7681' })
end

-- Execute shell command and return output
local function exec_command(cmd)
  local handle = io.popen(cmd .. ' 2>&1')
  if not handle then
    return nil, 'Failed to execute command'
  end
  local result = handle:read '*a'
  handle:close()
  return result
end

-- Get current git branch
local function get_current_branch()
  local result = exec_command 'git rev-parse --abbrev-ref HEAD'
  if result then
    return vim.trim(result)
  end
  return nil
end

-- Get repository information (owner/repo)
local function get_repo_info()
  local result = exec_command 'git config --get remote.origin.url'
  if not result then
    return nil, nil
  end

  result = vim.trim(result)

  -- Parse GitHub URL (supports both HTTPS and SSH)
  local owner, repo

  -- SSH format: git@github.com:owner/repo.git
  owner, repo = result:match 'git@github%.com:([^/]+)/(.+)%.git'

  -- HTTPS format: https://github.com/owner/repo.git
  if not owner then
    owner, repo = result:match 'https://github%.com/([^/]+)/(.+)%.git'
  end

  -- Without .git extension
  if not owner then
    owner, repo = result:match 'https://github%.com/([^/]+)/(.+)'
  end

  return owner, repo
end

-- Get PR number for current branch using gh CLI
local function get_pr_number(branch)
  local result = exec_command(string.format("gh pr list --head %s --json number --jq '.[0].number'", branch))
  if result and result ~= '' and result ~= 'null\n' then
    return vim.trim(result)
  end
  return nil
end

-- Fetch PR comments using gh CLI
local function fetch_pr_comments(owner, repo, pr_number)
  local cmd = string.format(
    "gh pr view %s --repo %s/%s --json comments --jq '.comments[] | {author: .author.login, body: .body, createdAt: .createdAt, path: .path, line: .line, position: .position}'",
    pr_number,
    owner,
    repo
  )

  local result = exec_command(cmd)
  if not result or result == '' then
    return {}
  end

  local comments = {}
  for line in result:gmatch '[^\r\n]+' do
    local ok, comment = pcall(vim.json.decode, line)
    if ok and comment then
      table.insert(comments, comment)
    end
  end

  return comments
end

-- Fetch review comments (inline comments on code) using gh CLI
local function fetch_review_comments(owner, repo, pr_number)
  local cmd = string.format(
    "gh api repos/%s/%s/pulls/%s/comments --jq '.[] | {author: .user.login, body: .body, createdAt: .created_at, path: .path, line: .line, original_line: .original_line}'",
    owner,
    repo,
    pr_number
  )

  local result = exec_command(cmd)
  if not result or result == '' then
    return {}
  end

  local comments = {}
  for line in result:gmatch '[^\r\n]+' do
    local ok, comment = pcall(vim.json.decode, line)
    if ok and comment then
      table.insert(comments, comment)
    end
  end

  return comments
end

-- Get relative path of current file from git root
local function get_relative_path(filepath)
  local git_root = exec_command 'git rev-parse --show-toplevel'
  if not git_root then
    return filepath
  end
  git_root = vim.trim(git_root)

  local rel_path = filepath:gsub('^' .. vim.pesc(git_root) .. '/', '')
  return rel_path
end

-- Format date to be more readable
local function format_date(date_str)
  if not date_str then
    return ''
  end

  -- Simple formatting - just extract date part
  local date = date_str:match '(%d%d%d%d%-%d%d%-%d%d)'
  return date or date_str
end

-- Truncate text to fit within reasonable width
local function truncate_text(text, max_width)
  max_width = max_width or 80
  if #text <= max_width then
    return text
  end
  return text:sub(1, max_width - 3) .. '...'
end

-- Clear all virtual text
local function clear_virtual_text()
  local bufnr = api.nvim_get_current_buf()
  api.nvim_buf_clear_namespace(bufnr, state.namespace, 0, -1)
end

-- Display comments as virtual text
local function display_comments()
  if not state.enabled then
    return
  end

  clear_virtual_text()

  local bufnr = api.nvim_get_current_buf()
  local current_file = api.nvim_buf_get_name(bufnr)
  local rel_path = get_relative_path(current_file)

  -- Filter comments for current file
  local file_comments = {}
  for _, comment in ipairs(state.comments) do
    if comment.path and comment.path == rel_path then
      local line = comment.line or comment.original_line
      if line then
        table.insert(file_comments, {
          line = line,
          author = comment.author,
          body = comment.body,
          date = format_date(comment.createdAt or comment.created_at),
        })
      end
    end
  end

  -- Sort by line number
  table.sort(file_comments, function(a, b)
    return a.line < b.line
  end)

  -- Display virtual text
  for _, comment in ipairs(file_comments) do
    local line_nr = comment.line - 1 -- 0-indexed for nvim API

    -- Get total line count to validate
    local line_count = api.nvim_buf_line_count(bufnr)
    if line_nr >= 0 and line_nr < line_count then
      -- Split comment body into lines for multi-line comments
      local body_lines = vim.split(comment.body, '\n')

      -- First line with author and date
      local header = string.format('💬 %s (%s):', comment.author, comment.date)
      api.nvim_buf_set_extmark(bufnr, state.namespace, line_nr, 0, {
        virt_text = { { header, 'GithubPRCommentAuthor' } },
        virt_text_pos = 'eol',
      })

      -- Comment body lines
      for i, body_line in ipairs(body_lines) do
        if i <= 3 then -- Limit to first 3 lines to avoid clutter
          local text = truncate_text(vim.trim(body_line), 100)
          if text ~= '' then
            api.nvim_buf_set_extmark(bufnr, state.namespace, line_nr, 0, {
              virt_lines = { { { string.format('  │ %s', text), 'GithubPRCommentText' } } },
            })
          end
        elseif i == 4 then
          api.nvim_buf_set_extmark(bufnr, state.namespace, line_nr, 0, {
            virt_lines = { { { string.format('  │ ... (%d more lines)', #body_lines - 3), 'GithubPRCommentDate' } } },
          })
          break
        end
      end
    end
  end

  if #file_comments > 0 then
    vim.notify(string.format('Displayed %d PR comment(s) for this file', #file_comments), vim.log.levels.INFO)
  else
    vim.notify('No PR comments found for this file', vim.log.levels.INFO)
  end
end

-- Load PR comments
local function load_pr_comments()
  local branch = get_current_branch()
  if not branch then
    vim.notify('Failed to get current git branch', vim.log.levels.ERROR)
    return false
  end

  local owner, repo = get_repo_info()
  if not owner or not repo then
    vim.notify('Failed to parse GitHub repository info', vim.log.levels.ERROR)
    return false
  end

  local pr_number = get_pr_number(branch)
  if not pr_number then
    vim.notify(string.format("No PR found for branch '%s'", branch), vim.log.levels.WARN)
    return false
  end

  vim.notify(string.format('Loading comments for PR #%s...', pr_number), vim.log.levels.INFO)

  state.pr_number = pr_number
  state.repo_owner = owner
  state.repo_name = repo

  -- Fetch both general comments and review comments
  local review_comments = fetch_review_comments(owner, repo, pr_number)

  state.comments = review_comments

  vim.notify(string.format('Loaded %d comment(s) from PR #%s', #state.comments, pr_number), vim.log.levels.INFO)

  return true
end

-- Toggle PR comments display
function M.toggle()
  if state.enabled then
    -- Disable
    state.enabled = false
    clear_virtual_text()
    vim.notify('PR comments hidden', vim.log.levels.INFO)
  else
    -- Enable
    if #state.comments == 0 then
      if not load_pr_comments() then
        return
      end
    end

    state.enabled = true
    display_comments()
  end
end

-- Refresh comments from GitHub
function M.refresh()
  if load_pr_comments() then
    if state.enabled then
      display_comments()
    end
  end
end

-- Show PR comments
function M.show()
  if #state.comments == 0 then
    if not load_pr_comments() then
      return
    end
  end

  if not state.enabled then
    state.enabled = true
  end

  display_comments()
end

-- Hide PR comments
function M.hide()
  state.enabled = false
  clear_virtual_text()
  vim.notify('PR comments hidden', vim.log.levels.INFO)
end

-- Populate quickfix list with PR comments
function M.quickfix()
  if #state.comments == 0 then
    if not load_pr_comments() then
      return
    end
  end

  local qf_list = {}
  local git_root = exec_command 'git rev-parse --show-toplevel'
  if not git_root then
    vim.notify('Failed to get git root directory', vim.log.levels.ERROR)
    return
  end
  git_root = vim.trim(git_root)

  -- Build quickfix entries
  for _, comment in ipairs(state.comments) do
    if comment.path then
      local line = comment.line or comment.original_line
      if line then
        local filepath = git_root .. '/' .. comment.path
        local text = string.format('[%s] %s', comment.author, comment.body:gsub('\n', ' '))

        table.insert(qf_list, {
          filename = filepath,
          lnum = line,
          col = 1,
          text = truncate_text(text, 200),
          type = 'I',
        })
      end
    end
  end

  if #qf_list == 0 then
    vim.notify('No PR comments with file locations found', vim.log.levels.WARN)
    return
  end

  -- Set quickfix list
  vim.fn.setqflist(qf_list, 'r')
  vim.fn.setqflist({}, 'a', {
    title = string.format('PR #%s Comments (%s/%s)', state.pr_number or '?', state.repo_owner or '?', state.repo_name or '?'),
  })

  -- Open quickfix window
  vim.cmd 'copen'
  vim.notify(string.format('Added %d PR comment(s) to quickfix list', #qf_list), vim.log.levels.INFO)
end

-- Setup function
function M.setup(opts)
  opts = opts or {}

  setup_highlights()

  -- Auto-refresh on buffer enter if enabled
  api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function()
      if state.enabled then
        display_comments()
      end
    end,
  })

  -- Create user commands
  api.nvim_create_user_command('GHPRToggle', M.toggle, { desc = 'Toggle GitHub PR comments' })
  api.nvim_create_user_command('GHPRRefresh', M.refresh, { desc = 'Refresh GitHub PR comments' })
  api.nvim_create_user_command('GHPRShow', M.show, { desc = 'Show GitHub PR comments' })
  api.nvim_create_user_command('GHPRHide', M.hide, { desc = 'Hide GitHub PR comments' })
  api.nvim_create_user_command('GHPRQuickfix', M.quickfix, { desc = 'Load PR comments into quickfix list' })

  -- Default keybindings (can be overridden)
  if opts.keybindings ~= false then
    vim.keymap.set('n', '<leader>gpt', M.toggle, { desc = 'Toggle GitHub PR comments' })
    vim.keymap.set('n', '<leader>gpr', M.refresh, { desc = 'Refresh GitHub PR comments' })
    vim.keymap.set('n', '<leader>gpq', M.quickfix, { desc = 'Load PR comments to quickfix' })
  end
end

return M
