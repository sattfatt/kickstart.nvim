return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'fredrikaverpil/neotest-golang',
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-golang',
        },
      }
    end,

    keys = {
      {
        '<leader>te',
        function()
          require('neotest').summary.open()
          require('neotest').run.run()
        end,
        mode = 'n',
        desc = 'Run nearest [t][e]st',
      },
    },
  },
}
