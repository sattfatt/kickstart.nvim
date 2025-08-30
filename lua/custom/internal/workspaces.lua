return {
  ['/Users/satyam/rockbot/go-rockbot/'] = function()
    vim.notify('Setting up rockbot go backend workspace', vim.log.levels.INFO)
    vim.keymap.set('n', '<leader>rg', function()
      require('custom.internal.run').run 'cd src/rockbot; set -a; source /Users/www/local.env; set +a; go run main.go'
    end, { desc = 'run rockbot go project' })
    vim.keymap.set('n', '<leader>rt', require('custom.internal.gotest').RunNearestGoTestV4, { desc = 'Run nearest go test' })
  end,
  ['/Users/satyam/rockbot/go-rockbot/src/rockbot/'] = function()
    vim.notify('Setting up rockbot go backend workspace', vim.log.levels.INFO)
    vim.keymap.set('n', '<leader>rg', function()
      require('custom.internal.run').run 'set -a; source /Users/www/local.env; set +a; go run main.go'
    end, { desc = 'run rockbot go project' })
    vim.keymap.set('n', '<leader>rt', require('custom.internal.gotest').RunNearestGoTestV4, { desc = 'Run nearest go test' })
  end,
  -- ['/Users/satyam/light-box'] = function()
  --   vim.keymap.set('n', '<leader>te', require('custom.internal.gotest').RunNearestGoTestV4, { desc = 'Run nearest go test' })
  -- end,
}
