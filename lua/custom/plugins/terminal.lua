return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = true,
    keys = {
      { '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = '[T]oggle [F]loating terminal' } },
    },
  },
}
