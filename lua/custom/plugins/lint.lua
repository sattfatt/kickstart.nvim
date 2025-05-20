-- lua/plugins/linting.lua
--
-- This file contains the lazy.nvim configuration for nvim-lint.
-- Ensure you have nvim-lint and the actual linter executables installed.
-- You can install linters using Mason:
-- :MasonInstall golangci-lint eslint_d ruff luacheck shellcheck

return {
  {
    'mfussenegger/nvim-lint',
    -- event = { 'BufReadPre', 'BufNewFile' }, -- Events to trigger loading of
    -- the plugin
    config = function()
      -- In your nvim-lint plugin configuration (e.g., using lazy.nvim)
      local lint = require 'lint'

      lint.linters_by_ft = {
        go = { 'golangcilint' },
      }

      -- Autocommand to trigger linting on save (ensure this is still relevant for your setup)
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'CursorHold', 'CursorHoldI', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('nvim-lint-golang', { clear = true }),
        callback = function(args)
          require('lint').try_lint()
        end,
      })
    end,
  },
}
