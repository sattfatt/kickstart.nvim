return {
  {
    'zgs225/gomodifytags.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    ft = 'go',
    cmd = { 'GoAddTags', 'GoRemoveTags' },
    build = function()
      -- Install the gomodifytags binary
      vim.system({ 'go', 'install', 'github.com/fatih/gomodifytags@latest' }, { text = true })
    end,
    config = function()
      require('gomodifytags').setup {
        transform = 'snakecase',
        override = false,
        sort = false,
      }

      -- Set up key mappings directly (they'll only apply to Go files)
      vim.keymap.set('n', '<leader>gt', ':GoAddTags json<CR>', { desc = 'Add [g]o JSON [t]ags' })

      vim.keymap.set('n', '<leader>gT', ':GoAddTags json,omitempty<CR>', { desc = 'Add [g]o JSON [T]ags with omitempty' })

      vim.keymap.set('n', '<leader>gr', ':GoRemoveTags json<CR>', { desc = '[R]emove [g]o JSON tags' })
    end,
  },
}
