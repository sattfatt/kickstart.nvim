local M = {}

M.setup = function()
  vim.api.nvim_create_user_command('GoAddTags', function(opts)
    local tag = opts.args or 'json'
    local cmd = string.format('gomodifytags -file %s -struct %s -add-tags %s -w', vim.fn.expand '%:p', vim.fn.expand '<cword>', tag)
    vim.fn.system(cmd)
    vim.cmd 'edit' -- Reload the buffer
  end, { nargs = '?' })

  vim.api.nvim_create_user_command('GoRemoveTags', function(opts)
    local tag = opts.args or 'json'
    local cmd = string.format('gomodifytags -file %s -struct %s -remove-tags %s -w', vim.fn.expand '%:p', vim.fn.expand '<cword>', tag)
    vim.fn.system(cmd)
    vim.cmd 'edit' -- Reload the buffer
  end, { nargs = '?' })
end

return M
