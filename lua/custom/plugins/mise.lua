return {
  {
    'sattfatt/mise.nvim',
    lazy = false, -- load eagerly for statusline/autocmds
    priority = 100,
    dependencies = {
      'folke/snacks.nvim',
    },
    opts = {
      terminal = {
        split = 'horizontal', -- "horizontal" | "vertical" | "float"
        height = 15, -- lines (horizontal split)
        width = 80, -- cols (vertical split)
      },
    }, -- use defaults, or customize (see Configuration)
    keys = {
      { '<leader>mt', '<cmd>MiseTools<cr>', desc = 'Mise Tools' },
      { '<leader>mr', '<cmd>MiseRun<cr>', desc = 'Mise Run Task' },
      { '<leader>mw', '<cmd>MiseWatch<cr>', desc = 'Mise Watch Task' },
      { '<leader>mi', '<cmd>MiseInstall<cr>', desc = 'Mise Install' },
      { '<leader>mu', '<cmd>MiseUpgrade<cr>', desc = 'Mise Upgrade' },
      { '<leader>mo', '<cmd>MiseOutdated<cr>', desc = 'Mise Outdated' },
      { '<leader>me', '<cmd>MiseEnv<cr>', desc = 'Mise Env' },
      { '<leader>mc', '<cmd>MiseConfig<cr>', desc = 'Mise Config' },
      { '<leader>mR', '<cmd>MiseRegistry<cr>', desc = 'Mise Registry' },
      { '<leader>mp', '<cmd>MisePlugins<cr>', desc = 'Mise Plugins' },
    },
  },
}
