return {
  {
    'folke/snacks.nvim',
    opts = {
      bigfile = {
        -- your bigfile configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      notifier = { enabled = true },
      input = { enabled = true },
      statuscolumn = { enabled = true },
      dim = {
        enabled = true,
        config = function()
          DIM_ENABLE = false
        end,
      },
      words = { enabled = true },
      indent = { enabled = true },
      toggle = {},
    },
    keys = {
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Git Browse',
      },
      {
        '<leader>hh',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Show [h]istory',
      },
      {
        '<lader>dd',
        function()
          Snacks.toggle.dim()
        end,
        desc = '[d]im some stuff',
      },
      {
        '<leader>ww',
        function()
          Snacks.words.jump(1, true)
        end,
        desc = 'show [w]ords',
      },
      {
        '<leader>xd',
        function()
          Snacks.toggle.diagnostics()
        end,
        desc = '[t]oggle [d]iagnostics',
      },
    },
  },
}
