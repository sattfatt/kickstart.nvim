local M = {}

function M.run_dt_workflows()
  local float = require 'plenary.window.float'

  local float_win = float.percentage_range_window(0.6, 0.6, {
    winblend = 0,
  }, {
    topleft = '╭',
    top = '─',
    topright = '╮',
    right = '│',
    botright = '╯',
    bot = '─',
    botleft = '╰',
    left = '│',
  })

  local win_id = float_win.win_id

  vim.fn.termopen('dt wf', {
    on_exit = function()
      vim.schedule(function()
        vim.api.nvim_win_close(win_id, true)
      end)
    end,
  })

  vim.cmd 'startinsert'
  -- vim.cmd 'terminal dt wf && exit'
end

function M.setup(opts)
  opts = opts or {}
  local keymap = opts.keymap or '<leader>dt'
  -- vim.keymap.set('n', keymap, M.run_dt_workflows, { desc = 'run [d]ev [t]ools workflows', noremap = true, silent = true })
end

return M
