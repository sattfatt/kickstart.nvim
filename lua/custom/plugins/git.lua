return {
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  {
    'sindrets/diffview.nvim',
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>dh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'git [d]iff current file [h]istory' })
      vim.keymap.set('n', '<leader>dh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'git [d]iff current file [h]istory' })
      vim.keymap.set('n', '<leader>dc', '<cmd>:DiffviewToggle', { desc = '[c]lose diffview' })
    end,
    keys = {},
  },
}
