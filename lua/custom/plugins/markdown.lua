return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'echasnovski/mini.nvim',
      {
        '3rd/diagram.nvim',
        dependencies = { { '3rd/image.nvim', opts = { max_width = 200, max_height = 50 } } },
        opts = {
          renderer_options = {
            mermaid = { background = '#1a1b26', theme = 'dark', width = 2000, height = 1200 },
          },
        },
      },
    }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    opts = {},
  },
  {
    'max397574/colortils.nvim',
    cmd = 'Colortils',
    config = function()
      require('colortils').setup()
    end,
  },
}
