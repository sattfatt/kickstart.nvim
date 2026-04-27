return {
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'lewis6991/async.nvim',
    },
    lazy = false,
    keys = {
      {
        '<leader>re',
        function()
          require('refactoring').select_refactor()
        end,
        mode = { 'n', 'x' },
        desc = 'Select refactor',
      },
    },
  },
}
