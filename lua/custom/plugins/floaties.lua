return {
  {
    'voldikss/vim-floaterm',
    opts = {},
    config = function()
      vim.api.nvim_set_hl(0, 'FloatermBorder', { link = 'TelescopeBorder' })
    end,
    keys = {
      {
        '<Leader>lg',
        function()
          vim.cmd 'FloatermNew --title=LazyGit --width=1.0 --height=1.0 lazygit'
        end,
        desc = 'Open lazy git',
      },
      {
        '<Leader>ld',
        function()
          vim.cmd 'FloatermNew --title=LazyDocker --width=1.0 --height=1.0 lazydocker'
        end,
        desc = 'Open lazy docker',
      },
      {
        '<Leader>lh',
        function()
          vim.cmd 'FloatermNew --title=Htop --width=1.0 --height=1.0 htop'
        end,
        desc = 'show system resources in htop',
      },
      {
        '<Leader>li',
        function()
          vim.cmd 'FloatermNew --title=JiraIssues --width=1.0 --height=1.0 jira issue list -a$(jira me) -Rx "done" -s "In Progress" -s "Selected For Development" -s "Engineering Backlog"'
        end,
        desc = 'Show my jira issues in backlog, selected for dev, and in progress',
      },
      {
        '<Leader>le',
        function()
          vim.cmd 'FloatermNew --title=JiraEpics --width=1.0 --height=1.0 jira epic list --table -a satyam.patel@rockbot.com -s "In Progress" -s "Selected For Development" -s "Engineering Backlog"'
        end,
        desc = 'Show my jira epics in backlog, selected for dev, and in progress',
      },
    },
  },
}
