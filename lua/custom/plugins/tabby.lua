return {
  'nanozuki/tabby.nvim',
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  keys = {
    { '<S-h>', '<cmd>tabprev<cr>', desc = 'Prev Tab' },
    { '<S-l>', '<cmd>tabnext<cr>', desc = 'Next Tab' },
    { '<leader>bo', '<cmd>tabonly<cr>', desc = 'Close Other Tabs' },
  },
  opts = {
    preset = 'tab_only',
  },
}
