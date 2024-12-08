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
  -- {
  --   'kdheepak/lazygit.nvim',
  --   cmd = {
  --     'LazyGit',
  --     'LazyGitConfig',
  --     'LazyGitCurrentFile',
  --     'LazyGitFilter',
  --     'LazyGitFilterCurrentFile',
  --   },
  --   -- optional for floating window border decoration
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --   },
  --   -- setting the keybinding for LazyGit with 'keys' is recommended in
  --   -- order to load the plugin when the command is run for the first time
  --   keys = {
  --     { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
  --   },
  --   config = function()
  --     vim.g.lazygit_floating_window_scaling_factor = 0.95 -- scaling factor for floating window
  --   end,
  -- },
  {
    'voldikss/vim-floaterm',
    keys = {
      {
        '<Leader>lg',
        function()
          vim.cmd 'FloatermNew --title=LazyGit --width=0.95 --height=0.95 lazygit'
        end,
        desc = 'LazyGit',
      },
    },
  },
}
