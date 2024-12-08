local M = {}

function M.diff_branch_modal(branch)
  local float = require 'plenary.window.float'
  -- Get the current file path
  local current_file = vim.fn.expand '%:p'

  -- Check if the current file exists
  if vim.fn.filereadable(current_file) == 0 then
    print 'Current file does not exist or is not readable.'
    return
  end

  -- Check if we're in a git repository
  local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true'
  if not is_git_repo then
    print 'Not in a git repository.'
    return
  end

  -- Check if the branch exists
  local branch_exists = vim.fn.system('git show-ref --verify --quiet refs/heads/' .. vim.fn.shellescape(branch) .. ' 2>/dev/null; echo $?'):match '0'
  if not branch_exists then
    print 'Specified branch does not exist.'
    return
  end

  -- Get the relative path of the current file in the git repository
  local relative_path = vim.fn.fnamemodify(current_file, ':~:.')

  -- Run git diff and capture the output
  local diff_command = string.format('git difftool %s:%s %s', vim.fn.shellescape(branch), vim.fn.shellescape(relative_path), vim.fn.shellescape(current_file))
  local diff_output = vim.fn.systemlist(diff_command)

  -- Create a new float window
  local float_win = float.percentage_range_window(0.9, 0.9, {
    winblend = 0,
    border = true,
    title = string.format('Diff: %s (%s vs current)', vim.fn.fnamemodify(current_file, ':t'), branch),
  })

  local win_id = float_win.win_id

  -- Get the buffer number of the float window
  local bufnr = vim.api.nvim_win_get_buf(win_id)

  local bal = require('baleia').setup {}

  -- Set buffer content
  bal.buf_set_lines(bufnr, 0, -1, false, diff_output)

  -- Set buffer options
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(bufnr, 'readonly', true)

  -- Set window options
  vim.api.nvim_win_set_option(win_id, 'wrap', false)
  vim.api.nvim_win_set_option(win_id, 'number', false)
  vim.api.nvim_win_set_option(win_id, 'relativenumber', false)

  -- Add keymapping to close the float window
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true })
end

-- Command to call the function
vim.api.nvim_create_user_command('DiffBranchModal', function(opts)
  M.diff_branch_modal(opts.args)
end, { nargs = 1, complete = 'custom,v:lua.get_git_branches' })

-- Function to get git branches for command completion
function _G.get_git_branches()
  local branches = vim.fn.systemlist 'git branch --format="%(refname:short)"'
  return table.concat(branches, '\n')
end

return M
