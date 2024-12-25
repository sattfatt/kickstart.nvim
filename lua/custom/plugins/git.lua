return {
  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    opts = {},
    config = function()
      vim.keymap.set('n', '<leader>gdh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'git [d]iff current file [h]istory' })
      vim.keymap.set('n', '<leader>gdc', '<cmd>:DiffviewClose<CR>', { desc = '[c]lose diffview' })
    end,
  },
}
