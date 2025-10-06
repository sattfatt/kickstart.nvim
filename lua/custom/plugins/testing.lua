return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      {
        'fredrikaverpil/neotest-golang',
        version = '*', -- Optional, but recommended; track releases
        build = function()
          vim.system({ 'go', 'install', 'gotest.tools/gotestsum@latest' }):wait() -- Optional, but recommended
        end,
      },
    },
    config = function()
      -- Helper function to parse a .env file into a Lua table
      local function load_env(env_file)
        local env = {}
        -- Open the file for reading
        local file = io.open(env_file, 'r')
        if not file then
          -- Silently fail if the file doesn't exist, or you can print a warning
          -- print("neotest: .env file not found at " .. env_file)
          return {}
        end

        -- Iterate over each line in the file
        for line in file:lines() do
          -- Match lines in the format KEY=VALUE, ignoring comments (#) and empty lines
          local key, value = line:match '^%s*([^%s#=]+)%s*=%s*(.*)$'

          if key and value then
            -- Optional: remove surrounding quotes from the value
            value = value:match '^"(.*)"$' or value:match "^'(.*)'$" or value
            env[key] = value
          end
        end

        file:close()
        return env
      end

      local config = {
        runner = 'gotestsum', -- Optional, but recommended
        env = load_env '/Users/www/local.env',
      }

      require('neotest').setup {
        adapters = {
          require 'neotest-golang'(config),
        },
      }
    end,

    keys = {
      {
        '<leader>te',
        function()
          require('neotest').run.run()
          require('neotest').output.open { follow = true }
        end,
        mode = 'n',
        desc = 'Neotest: Run nearest [t][e]st',
      },
      {
        '<leader>to',
        function()
          require('neotest').output_panel.open { follow = true }
        end,
        mode = 'n',
        desc = 'Neotest: show [t]est [o]utput',
      },
      {
        '<leader>tt',
        function()
          require('neotest').output_panel.clear()
        end,
        mode = 'n',
        desc = 'Neotest: show [t]est [o]utput',
      },
    },
  },
}
