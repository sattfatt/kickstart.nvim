return {
  {
    'folke/sidekick.nvim',
    opts = {
      cli = {
        prompts = {
          implement = {
            msg = "Implement what I've described in the comment at this location",
            location = { row = true, col = false },
          },
        },
      },
    },
    keys = {
      {
        '<tab>',
        function()
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>'
          end
        end,
        expr = true,
        desc = 'NES jump/apply',
      },
      {
        '<leader>ac',
        function()
          require('sidekick.cli').toggle { name = 'claude', focus = true }
        end,
        desc = 'Claude CLI',
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').prompt()
        end,
        desc = 'Select prompt',
        mode = { 'n', 'v' },
      },
    },
  },
}
