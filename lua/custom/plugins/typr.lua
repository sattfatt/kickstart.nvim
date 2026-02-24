return {
  {
    'nvzone/typr',
    dependencies = 'nvzone/volt',
    opts = {},
    cmd = { 'Typr', 'TyprStats' },
    keys = {
      { '<leader>ty', '<cmd>Typr<cr>', desc = 'Typr' },
      { '<leader>ts', '<cmd>TyprStats<cr>', desc = 'TyprStats' },
    },
  },
}
