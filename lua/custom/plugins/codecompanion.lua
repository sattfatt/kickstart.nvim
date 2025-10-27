return {
  {
    'olimorris/codecompanion.nvim',
    opts = {
      strategies = {
        chat = {
          adapter = 'claude_code',
        },
      },
      adapters = {
        acp = {
          claude_code = function()
            return require('codecompanion.adapters').extend('claude_code', {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = 'cmd:cat ~/.claude-token',
              },
            })
          end,
        },
      },
    },
    keys = {
      {
        '<leader>cc',
        '<cmd>CodeCompanionActions<cr>',
        desc = 'Code Companion Actions',
      },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },
}
