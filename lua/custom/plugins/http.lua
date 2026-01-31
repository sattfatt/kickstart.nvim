return {
  {
    'rest-nvim/rest.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, 'http')

        vim.g.rest_nvim = {
          env = {
            enable = true,
            pattern = '.*%.env.*',
            find = function()
              local config = require 'rest-nvim.config'
              return vim.fs.find(function(name, _)
                return name:match(config.env.pattern)
              end, {
                path = '~/envs/http/',
                type = 'file',
                limit = math.huge,
              })
            end,
          },
          response = {
            ---Default response hooks
            hooks = {
              decode_url = true,
              format = true,
            },
          },
        }

        vim.keymap.set('n', '<leader>ao', ':vert Rest open<CR>', { desc = '[a]pi [o]pen [a]pi http result pane' })
        vim.keymap.set('n', '<leader>ar', ':vert Rest run<CR>', { desc = '[a]pi [r]un http under cursor' })
        vim.keymap.set('n', '<leader>ae', ':Rest env select<CR>', { desc = '[a]pi [s]elect env to use' })
      end,
    },
  },
}
