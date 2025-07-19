return {
  {
    'L3MON4D3/LuaSnip',
    build = 'make install_jsregexp',
    dependencies = {
      {
        'rafamadriz/friendly-snippets',
        config = function() end,
      },
    },
    config = function()
      require('luasnip').filetype_extend('vue', { 'javascript', 'typescript' })
      require('luasnip.loaders.from_vscode').lazy_load()
    end,
  },

  { -- Autocompletion and snippets
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
      -- Snippet Engine & its associated nvim-cmp source
    },
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },
      completion = { documentation = { auto_show = true } },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          sql = { 'snippets', 'dadbod', 'buffer' },
          mysql = { 'snippets', 'dadbod', 'buffer' },
        },
        -- add vim-dadbod-completion to your completion providers
        providers = {
          dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        },
      },
      -- See the fuzzy documentation for more information
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },
}
