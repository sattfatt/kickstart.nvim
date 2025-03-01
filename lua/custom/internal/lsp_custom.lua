local M = {}

function M.debug_log(message)
  -- Create a log file in /tmp
  local log_file = '/tmp/nvim-lsp-debug.log'
  local file = io.open(log_file, 'a')
  if file then
    local timestamp = os.date '%Y-%m-%d %H:%M:%S'
    file:write(string.format('[%s] %s\n', timestamp, message))
    file:close()
  end
end

function M.setup(capabilities)
  local configs = require 'lspconfig.configs'
  local lspconfig = require 'lspconfig'
  local util = lspconfig.util

  -- Check if our config already exists
  if not configs.dev_tools_lsp then
    configs.dev_tools_lsp = {
      default_config = {
        cmd = { vim.fn.expand '~/dev-tools-lsp/main' },
        filetypes = { 'sh', 'bash' },
        root_dir = function(fname)
          M.debug_log('Searching for root directory for file: ' .. fname)

          local root = util.root_pattern 'dev-tools.txt'(fname)
          if root then
            M.debug_log('found root with dev-tools.txt at: ' .. root)
          else
            M.debug_log 'no dev-tools txt found'
          end

          local git_root = vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
          if git_root then
            M.debug_log('Found git root at: ' .. git_root)
          else
            M.debug_log 'No git root found'
          end

          local final_root = root or git_root or vim.loop.os_homedir()
          M.debug_log('Using root directory: ' .. final_root)

          return final_root
        end,
        -- workspace = { workspaceFolders = true }
        capabilities = vim.tbl_extend('force', capabilities, vim.lsp.protocol.make_client_capabilities(), {}),
        settings = {},
      },
    }
  end

  -- Set up the server
  lspconfig.dev_tools_lsp.setup {}
end

return M
