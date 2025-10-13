return {
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('refactoring').setup {
        vim.keymap.set('x', '<leader>re', ':Refactor extract '),
      }
    end,
  },
}
