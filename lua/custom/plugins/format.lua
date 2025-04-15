return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          -- format with formatter
          require('conform').format { async = true, lsp_fallback = true }

          -- format with eslint
          pcall(function()
            local filetype = vim.bo.filetype
            if filetype == 'vue' or filetype == 'javascript' or filetype == 'typescript' then
              vim.notify 'running eslint fixall'
              vim.cmd 'EslintFixAll'
              return
            end
          end)
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    config = function()
      require('conform').setup {
        notify_on_error = false,
        format_on_save = function(bufnr)
          -- Disable "format_on_save lsp_fallback" for languages that don't
          -- have a well standardized coding style. You can add additional
          -- languages here or re-enable it for the disabled ones.
          local disable_filetypes = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          templ = { 'templ' },
          go = { 'gofmt' },
          sql = { 'sqlfmt' },
          vue = { 'prettier' },
          javascript = { 'prettier' },
          typescript = { 'prettierd', 'prettier' },
          -- Conform can also run multiple formatters sequentially
          -- python = { "isort", "black" },
          --
          -- You can use a sub-list to tell conform to run *until* a formatter
          -- is found.
          -- javascript = { { "prettierd", "prettier" } },
        },
      }
      require('conform').formatters.injected = {
        -- Set the options field
        options = {
          -- Set individual option values
          ignore_errors = true,
          lang_to_formatters = {
            sql = { 'sqlfmt' },
          },
        },
      }
    end,
  },
}
