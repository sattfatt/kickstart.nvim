return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      'kristijanhusak/vim-dadbod-completion',
      'kristijanhusak/vim-dadbod-ui',
    },
    config = function()
      vim.g.db_ui_save_location = vim.fn.stdpath 'config' .. '/db_ui'

      vim.g.dbs = {
        dev = 'mysql:///dev_latest?login-path=dev',
        replica = 'mysql:///rockbot_prod?login-path=replica',
      }

      vim.keymap.set('n', '<leader>db', ':tabnew<CR>:DBUI<CR>', { noremap = true, silent = true, desc = 'Open DB in another tab' })
    end,
  },
}
