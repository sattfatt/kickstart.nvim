local M = {}

local function get_nearest_go_test()
  -- Save the current cursor position
  local save_cursor = vim.fn.getpos '.'

  -- Search for the next test function
  if vim.fn.search([[\v^func\s+Test\w+\(]], 'nW') == 0 then
    -- If not found forward, search backward
    if vim.fn.search([[\v^func\s+Test\w+\(]], 'bnW') == 0 then
      return ''
    end
  end

  -- Get the line containing the test function
  local test_line = vim.fn.getline '.'

  -- Extract the test name using regex
  local test_name = vim.fn.matchstr(test_line, [[\vTest\w+]])

  -- Restore the cursor position
  vim.fn.setpos('.', save_cursor)

  return test_name
end

M.RunNearestGoTest = function()
  vim.cmd 'write'
  local current_file_dir = vim.fn.expand '%:p:h'
  local nearest_test = get_nearest_go_test()

  local cmd = string.format('cd %s && GOPATH=/Users/www/go-rockbot go test -v -run %s', current_file_dir, nearest_test)

  vim.cmd 'belowright new'
  local job_id = vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        print('Test command failed with exit code: ' .. exit_code)
      end
    end,
  })

  if job_id == 0 then
    print 'Failed to start the test command'
    vim.cmd 'bdelete!'
  else
    vim.cmd 'startinsert'
  end
end

return M
