local M = {}

function M.run_dt_workflows()
  vim.cmd 'enew'
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.termopen('dt wf', {
    on_exit = function()
      vim.schedule(function()
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end)
    end,
  })

  vim.cmd 'startinsert'
  -- vim.cmd 'terminal dt wf && exit'
end

function M.setup(opts)
  opts = opts or {}
  local keymap = opts.keymap or '<leader>dt'
  vim.api.nvim_set_keymap(
    'n',
    keymap,
    '<cmd>lua require("workflows").run_dt_workflows()<CR>',
    { desc = 'run [d]ev [t]ools workflows', noremap = true, silent = true }
  )
end

return M
