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
  {
    'voldikss/vim-floaterm',
    keys = {
      {
        '<Leader>lg',
        function()
          vim.cmd 'FloatermNew --title=LazyGit --width=0.99 --height=0.99 lazygit'
        end,
        desc = 'Open lazy git',
      },
      {
        '<Leader>ld',
        function()
          vim.cmd 'FloatermNew --title=LazyDocker --width=0.99 --height=0.99 lazydocker'
        end,
        desc = 'Open lazy docker',
      },
      {
        '<Leader>lh',
        function()
          vim.cmd 'FloatermNew --title=htop --width=0.99 --height=0.99 htop'
        end,
        desc = 'show system resources in htop',
      },
      {
        '<Leader>li',
        function()
          vim.cmd 'FloatermNew --title=jira --width=0.99 --height=0.99 jira issue list -a$(jira me) -Rx "done" -s "In Progress" -s "Selected For Development" -s "Engineering Backlog"'
        end,
        desc = 'Show my jira issues in backlog, selected for dev, and in progress',
      },
      {
        '<Leader>le',
        function()
          vim.cmd 'FloatermNew --title=epics --width=0.99 --height=0.99 jira epic list --table -a satyam.patel@rockbot.com -s "In Progress" -s "Selected For Development" -s "Engineering Backlog"'
        end,
        desc = 'Show my jira epics in backlog, selected for dev, and in progress',
      },
    },
  },
}
