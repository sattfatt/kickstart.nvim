local M = {}

-- Function to run a command in a new tab terminal (interactive) and close on tab exit
M.run = function(command)
  -- Check if a tab is already running this command
  for i = 1, vim.fn.tabpagenr '$' do
    local existing_cmd = vim.fn.gettabvar(i, 'running_cmd', '')
    if existing_cmd == command then
      vim.cmd('tabnext ' .. i) -- Switch to existing tab
      return
    end
  end

  -- Open a new tab
  vim.cmd 'tabnew'

  -- Start a terminal session in interactive mode
  vim.cmd('terminal ' .. command) -- Run the command directly in a new terminal

  -- Get terminal job ID
  local job_id = vim.b.terminal_job_id

  -- Store job ID and command for tracking
  vim.fn.settabvar(vim.fn.tabpagenr(), 'running_cmd', command)
  vim.fn.settabvar(vim.fn.tabpagenr(), 'job_id', job_id)

  -- Set up an autocommand to kill the process when the tab closes
  vim.cmd(string.format(
    [[
        autocmd TabClosed <buffer> lua vim.fn.jobstop(%d)
        ]],
    job_id
  ))
end

-- Setup function to register the `:RunInNewTab` command
M.setup = function()
  vim.api.nvim_create_user_command('RunInNewTab', function(opts)
    M.run(opts.args)
  end, { nargs = 1, complete = 'shellcmd' })
end

return M
