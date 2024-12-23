local M = {}

M.RunNearestGoTestV4 = function()
  vim.cmd 'write'
  local current_file_dir = vim.fn.expand '%:p:h'
  local nearest_test = require('custom.internal.testfinder').get_test_name()
  print('nearest:', nearest_test)
  if not nearest_test then
    print 'could not find test at cursor'
    return
  end

  local temp_file = os.tmpname()

  --  'set -a; source /Users/www/local.env; set +a; cd %s && GOPATH=/Users/www/go-rockbot go test -v -run %s | grcat ~/.grc/conf.gotest > %s 2>&1',

  local cmd = string.format(
    'set -a; source /Users/www/local.env; set +a; cd %s && GOPATH=/Users/www/go-rockbot go test -v -run %s > %s 2>&1',
    current_file_dir,
    nearest_test,
    temp_file
  )

  -- Create new buffer for output
  vim.cmd 'belowright new'
  local buf = vim.api.nvim_get_current_buf()

  -- Set up buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_name(buf, 'GoTest Output')

  -- Set up the quit mapping
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', {
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.format('Running: %s ...', nearest_test) })

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
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- replace ansi with hightlights

      -- require('custom.internal.ansitohighlight').run()

      -- Delete the temp file
      os.remove(temp_file)

      -- -- Set cursor at top
      -- vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Make buffer read-only
      vim.api.nvim_buf_set_option(buf, 'modified', false)
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      vim.api.nvim_buf_set_option(buf, 'filetype', 'injection')
      -- vim.treesitter.language.add_to_buffer(buf, 'injection')
      -- vim.treesitter.start(buf, 'injection')
    end,
  })
end

return M
