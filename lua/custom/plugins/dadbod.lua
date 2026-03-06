local function ensure_db_proxy(env, port)
  vim.fn.system('pgrep -f "rockbot db-connect --env ' .. env .. '"')
  if vim.v.shell_error ~= 0 then
    vim.fn.jobstart({ 'rockbot', 'db-connect', '--env', env, '--port', tostring(port) }, { detach = true })
    vim.notify('Started rockbot db-connect --env ' .. env .. ' --port ' .. port)
  end
end

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
        dev = 'mysql://satyam.patel@127.0.0.1:1233/dev_latest',
        replica = 'mysql://satyam.patel@127.0.0.1:1234/rockbot_prod',
        localhost = 'mysql://root@localhost/mysqltestdb',
      }
    end,
    cmd = { 'DBUI' },
    keys = {
      {
        '<Leader>db',
        function()
          ensure_db_proxy('dev', 1233)
          ensure_db_proxy('stage', 1234)
          vim.cmd 'tabnew | DBUI'
        end,
        desc = 'Open DB UI',
      },
    },
  },
}
