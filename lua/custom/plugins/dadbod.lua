return {
  {
    'tpope/vim-dadbod',
    dependencies = {
      'kristijanhusak/vim-dadbod-completion',
      'kristijanhusak/vim-dadbod-ui',
      {
        'napisani/nvim-dadbod-bg',
        build = './install.sh',
        -- (optional) the default port is 4546
        -- (optional) the log file will be created in the system's temp directory
        config = function()
          vim.cmd [[
            let g:nvim_dadbod_bg_port = '4546'
            let g:nvim_dadbod_bg_log_file = '/tmp/nvim-dadbod-bg.log'
          ]]
        end,
      },
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
