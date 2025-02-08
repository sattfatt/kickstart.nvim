return {
  ['/Users/satyam/rockbot/go-rockbot'] = function()
    vim.notify('Setting up rockbot go backend workspace', 'info')
    vim.keymap.set('n', '<leader>rg', function()
      require('custom.internal.run').run 'cd src/rockbot; set -a; source /Users/www/local.env; set +a; go run main.go'
    end, { desc = 'run rockbot go project' })
    vim.keymap.set('n', '<leader>te', require('custom.internal.gotest').RunNearestGoTestV4, { desc = 'Run nearest go test' })
  end,
}
