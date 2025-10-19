local M = {}

local uuid = function()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

  return string.gsub(template, '[xy]', function(c)
    local v = vim.fn.rand() % 16
    if c == 'y' then
      v = (v % 4) + 8
    end
    return string.format('%x', v)
  end)
end

local state = {
  current_win = 0,
  current_buff = 0,
}

local closeExisting = function()
  if state.current_win > 0 then
    pcall(function()
      vim.api.nvim_win_close(state.current_win, true)
    end)
  end
end

M.GetGoTestCommand = function()
  local nearest_test = require('custom.internal.testfinder').get_test_name()
  local cmd = string.format('go test -v -run %s', nearest_test)
  return cmd
end

M.CopyTestCommandToClipboard = function()
  local cmd = M.GetGoTestCommand()
  vim.fn.setreg('+', cmd)
  local log = string.format('test command saved to clipboard:\n%s', cmd)
  vim.notify(log, vim.log.levels.INFO)
end

M.RunNearestGoTestV4 = function()
  closeExisting()

  vim.cmd 'write'
  local current_file_dir = vim.fn.expand '%:p:h'
  local nearest_test = require('custom.internal.testfinder').get_test_name()
  if not nearest_test then
    vim.notify 'could not find test at cursor'
    return
  end

  local temp_file = os.tmpname() .. uuid()

  --  'set -a; source /Users/www/local.env; set +a; cd %s && GOPATH=/Users/www/go-rockbot go test -v -run %s | grcat ~/.grc/conf.gotest > %s 2>&1',

  local cmd = string.format(
    'set -a; source /Users/www/local.env; set +a; cd %s && GOPATH=/Users/www/go-rockbot go test -v -run %s > %s 2>&1',
    current_file_dir,
    nearest_test,
    temp_file
  )

  -- Create new buffer for output
  vim.cmd 'belowright new'
  state.current_buff = vim.api.nvim_get_current_buf()
  state.current_win = vim.api.nvim_get_current_win()

  -- Set up buffer options
  vim.api.nvim_buf_set_option(state.current_buff, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(state.current_buff, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(state.current_buff, 'swapfile', false)
  vim.api.nvim_buf_set_name(state.current_buff, 'GoTest Output')

  -- Set up the quit mapping
  vim.api.nvim_buf_set_keymap(state.current_buff, 'n', 'q', ':q<CR>', {
    noremap = true,
    silent = true,
  })

  local notif = string.format('Running: %s ...', nearest_test)
  vim.api.nvim_buf_set_lines(state.current_buff, 0, -1, false, { notif })
  vim.notify(notif)

  -- Run the test in a job
  vim.fn.jobstart(cmd, {
    on_exit = function()
      -- Read the temp file
      local lines = vim.fn.readfile(temp_file)

      vim.list_extend(lines, {
        '',
        'Press q to exit',
      })

      -- Add the content to our buffer
      vim.api.nvim_buf_set_lines(state.current_buff, 0, -1, false, lines)

      -- replace ansi with hightlights

      -- require('custom.internal.ansitohighlight').run()

      -- Delete the temp file
      os.remove(temp_file)

      -- -- Set cursor at top
      -- vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Make buffer read-only
      vim.api.nvim_buf_set_option(state.current_buff, 'modified', false)
      vim.api.nvim_buf_set_option(state.current_buff, 'modifiable', false)
      vim.api.nvim_buf_set_option(state.current_buff, 'filetype', 'txt')
      -- vim.treesitter.language.add_to_buffer(buf, 'injection')
      -- vim.treesitter.start(buf, 'injection')
    end,
  })
end

return M
