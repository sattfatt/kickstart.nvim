return {
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`

      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            override_vim_notify = true,
          },
        },
      },
      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
      { 'saghen/blink.cmp' },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).

          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end

          -- handle bashls + dev-tools-ls worspace conflict
          local bufnr = event.buf
          local allClients = vim.lsp.get_clients { bufnr = bufnr }
          -- Check if multiple clients support workspace symbols
          local workspace_symbol_providers = {}
          for _, cl in ipairs(allClients) do
            if cl.server_capabilities.workspaceSymbolProvider then
              table.insert(workspace_symbol_providers, cl)
            end
          end

          if #workspace_symbol_providers > 1 then
            -- Keep workspace symbols only for your preferred server
            -- In this case, we'll keep it for your custom server and disable for bash-language-server
            for _, cl in ipairs(workspace_symbol_providers) do
              if cl.name == 'bashls' then -- Change to match the name of the LSP you want to disable
                cl.server_capabilities.workspaceSymbolProvider = false
                print('Disabled workspace symbols for ' .. cl.name .. ' (multiple providers detected)')
              end
            end
          end

          local hasDevToolsLSP = false
          for _, cl in ipairs(workspace_symbol_providers) do
            if cl.name == 'dev_tools_lsp' then
              hasDevToolsLSP = true
            end
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          map('<leader>co', require('telescope.builtin').lsp_outgoing_calls, '[C]alls [O]utgoing')
          map('<leader>ci', require('telescope.builtin').lsp_incoming_calls, '[C]alls [I]ncoming')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- -- Fuzzy find all the symbols in your current document.
          -- --  Symbols are things like variables, functions, types, etc.
          -- map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          if hasDevToolsLSP then
            map('<leader>ss', require('telescope.builtin').lsp_workspace_symbols, '[W]orkspace [S]ymbols')
          else
            map('<leader>ss', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          end
          --
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      local capabilities = require('blink.cmp').get_lsp_capabilities(nil, true)

      vim.filetype.add { extension = { templ = 'templ' } }
      vim.filetype.add { extension = { brs = 'brs' } }

      local servers = {
        gopls = {
          on_attach = function()
            -- load sql too
            vim.treesitter.language.register('go', 'sql')

            -- automatically organize imports on save ...
            -- vim.api.nvim_create_autocmd('BufWritePre', {
            --   pattern = '*.go',
            --   callback = function()
            --     local params = vim.lsp.util.make_range_params()
            --     params.context = { only = { 'source.organizeImports' } }
            --
            --     -- Synchronously organize imports
            --     local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
            --     for _, res in pairs(result or {}) do
            --       for _, r in pairs(res.result or {}) do
            --         if r.edit then
            --           vim.lsp.util.apply_workspace_edit(r.edit, 'utf-8')
            --         else
            --           vim.lsp.buf.execute_command(r.command)
            --         end
            --       end
            --     end
            --   end,
            -- })
          end,
        },

        templ = {},

        bright_script = {
          filetypes = { 'brs' },
          settings = {
            brightscript = {
              configFile = vim.fn.getcwd() .. '/bsconfig.json',
            },
          },
        },

        html = {
          filetypes = { 'html', 'templ' },
        },

        jsonls = {},

        volar = {},

        tailwindcss = {
          includeLanguages = {
            templ = 'html',
          },
        },

        ts_ls = {
          init_options = {
            plugins = {
              {
                name = '@vue/typescript-plugin',
                location = '/Users/satyam/Library/pnpm/global/5/node_modules/@vue/typescript-plugin',
                languages = { 'javascript', 'typescript', 'vue' },
              },
            },
          },
          filetypes = {
            'javascript',
            'typescript',
            'vue',
          },
        },

        cssls = {},

        markdown_oxide = {
          workspace = {
            didChangeWatchedFiles = {
              dynamicRegistration = true,
            },
          },
        },

        eslint = {},

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },

        pylsp = {},

        bashls = {},
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      ---@diagnostic disable-next-line: missing-fields
      require('mason-lspconfig').setup {
        -- ensure_installed = ensure_installed,
        -- automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }

      require('custom.internal.lsp_custom').setup(capabilities)
    end,
  },
}
