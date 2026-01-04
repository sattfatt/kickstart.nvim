local function load_env()
  local home = os.getenv 'HOME'
  local lines = vim.fn.readfile '/Users/www/local.env'
  for _, line in ipairs(lines) do
    line = line:gsub('^export%s+', '')
    local key, val = line:match '^([%w_]+)=(.+)$'
    if key and val then
      val = val:gsub('%$HOME', home)
      vim.fn.setenv(key, val)
    end
  end
end

local function with_env(cmd)
  return function()
    load_env()
    vim.cmd(cmd)
  end
end

return {
  {
    'ray-x/go.nvim',
    dependencies = {
      'ray-x/guihua.lua',
      'neovim/nvim-lspconfig',
      'nvim-treesitter/nvim-treesitter',
    },
    opts = {},
    config = function(_, opts)
      require('go').setup(opts)
      local format_sync_grp = vim.api.nvim_create_augroup('GoFormat', {})
      vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = '*.go',
        callback = function()
          require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = { 'CmdlineEnter' },
    ft = { 'go', 'gomod' },
    build = ':lua require("go.install").update_all_sync()',
    keys = {
      { '<leader>te', with_env 'GoTestFunc -v', desc = 'run nearest test' },
      { '<leader>tf', with_env 'GoTestFile -v', desc = 'run file tests' },
      { '<leader>tp', with_env 'GoTestPkg -v', desc = 'run package tests' },
    },
  },
}
