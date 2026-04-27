return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      -- Install core parsers (no-op if already installed)
      require('nvim-treesitter').install({
        'sql', 'bash', 'c', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc',
        'go', 'javascript', 'typescript', 'toml',
      })

      -- Enable treesitter features for all filetypes
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(ev)
          local ft = ev.match

          -- Enable treesitter highlighting (skip ruby which relies on regex highlighting)
          if ft ~= 'ruby' then
            pcall(vim.treesitter.start)
          end

          -- Enable treesitter folds
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'

          -- Enable treesitter indentation (skip ruby)
          if ft ~= 'ruby' then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end

          -- Auto-install missing parsers (only if nvim-treesitter knows the parser)
          local lang = vim.treesitter.language.get_lang(ft)
          if lang and require('nvim-treesitter.parsers')[lang] ~= nil then
            local ok = pcall(vim.treesitter.language.inspect, lang)
            if not ok then
              pcall(require('nvim-treesitter').install, { lang })
            end
          end
        end,
      })

      -- mojo treesitter parser
      local parsers = require('nvim-treesitter.parsers')
      ---@diagnostic disable-next-line: inject-field
      parsers.mojo = {
        install_info = {
          url = 'https://github.com/lsh/tree-sitter-mojo',
          files = { 'src/parser.c', 'src/scanner.c' },
          branch = 'main',
        },
      }
      vim.filetype.add({
        extension = {
          mojo = 'mojo',
          ['🔥'] = 'mojo',
        },
      })

      -- brightscript: register filetype mapping (parser compiled separately)
      vim.treesitter.language.register('brightscript', 'brs')
    end,
  },
}
