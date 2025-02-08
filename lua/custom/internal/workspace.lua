local M = {}

M.workspaces = require 'custom.internal.workspaces'

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ':p') -- Convert relative to absolute path
end

local function run_workspace_setup()
  local cwd = normalize_path(vim.uv.cwd()) -- Normalize cwd
  vim.notify('Current cwd: ' .. cwd, 'info') -- Debugging output

  for workspace_path, setup_func in pairs(M.workspaces) do
    if cwd:find(workspace_path, 1, true) == 1 then -- Match workspace
      vim.notify('Matched workspace: ' .. workspace_path, 'info')
      setup_func()
      return -- Stop after the first match
    end
  end

  print('No workspace setup found for:', cwd)
end

function M.setup()
  -- Run once on startup
  run_workspace_setup()

  -- Clear previous autocommands to avoid duplicates
  local group_id = vim.api.nvim_create_augroup('WorkspaceSetup', { clear = true })

  -- Create autocommand to rerun setup when the working directory changes
  vim.api.nvim_create_autocmd('DirChanged', {
    group = group_id,
    callback = function()
      run_workspace_setup()
    end,
  })
end

return M
