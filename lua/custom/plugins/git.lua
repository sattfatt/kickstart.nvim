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
      vim.keymap.set('n', '<leader>dh', '<cmd>:DiffviewFileHistory %<CR>', { desc = 'git [d]iff current file [h]istory' })
      vim.keymap.set('n', '<leader>dc', '<cmd>:DiffviewClose<CR>', { desc = '[c]lose diffview' })
    end,
  },
  {
    'voldikss/vim-floaterm',
    keys = {
      {
        '<Leader>lg',
        function()
          vim.cmd 'FloatermNew --title=LazyGit --width=0.99 --height=0.99 lazygit'
        end,
        desc = 'LazyGit',
      },
      {
        '<Leader>ld',
        function()
          vim.cmd 'FloatermNew --title=LazyDocker --width=0.99 --height=0.99 lazydocker'
        end,
        desc = 'LazyDocker',
      },
      {
        '<Leader>lh',
        function()
          vim.cmd 'FloatermNew --title=htop --width=0.99 --height=0.99 htop'
        end,
        desc = 'htop',
      },
    },
  },
}
