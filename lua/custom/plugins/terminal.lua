return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = true,
    keys = {
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = '[T]oggle [F]loating terminal' } },
    },
  },

  {
    'https://git.sr.ht/~havi/telescope-toggleterm.nvim',
    event = 'TermOpen',
    requires = {
      'akinsho/nvim-toggleterm.lua',
      'nvim-telescope/telescope.nvim',
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('telescope').load_extension 'toggleterm'
    end,
  },
}
