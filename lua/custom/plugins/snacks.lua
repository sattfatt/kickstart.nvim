return {
  {
    'folke/snacks.nvim',
    opts = {
      bigfile = {
        -- your bigfile configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      },
      ---@class snacks.image.Config
      ---@field enabled? boolean enable image viewer
      ---@field wo? vim.wo|{} options for windows showing the image
      ---@field bo? vim.bo|{} options for the image buffer
      ---@field formats? string[]
      --- Resolves a reference to an image with src in a file (currently markdown only).
      --- Return the absolute path or url to the image.
      --- When `nil`, the path is resolved relative to the file.
      ---@field resolve? fun(file: string, src: string): string?
      ---@field convert? snacks.image.convert.Config
      image = {
        formats = {
          'png',
          'jpg',
          'jpeg',
          'gif',
          'bmp',
          'webp',
          'tiff',
          'heic',
          'avif',
          'mp4',
          'mov',
          'avi',
          'mkv',
          'webm',
          'pdf',
        },
        force = false, -- try displaying the image, even if the terminal does not support it
        doc = {
          -- enable image viewer for documents
          -- a treesitter parser must be available for the enabled languages.
          enabled = true,
          -- render the image inline in the buffer
          -- if your env doesn't support unicode placeholders, this will be disabled
          -- takes precedence over `opts.float` on supported terminals
          inline = true,
          -- render the image in a floating window
          -- only used if `opts.inline` is disabled
          float = false,
          max_width = 80,
          max_height = 40,
          -- Set to `true`, to conceal the image text when rendering inline.
          -- (experimental)
          ---@param lang string tree-sitter language
          ---@param type snacks.image.Type image type
          conceal = false,
        },
        img_dirs = { 'img', 'images', 'assets', 'static', 'public', 'media', 'attachments', 'Pictures' },
        -- window options applied to windows displaying image buffers
        -- an image buffer is a buffer with `filetype=image`
        wo = {
          wrap = false,
          number = false,
          relativenumber = false,
          cursorcolumn = false,
          signcolumn = 'no',
          foldcolumn = '0',
          list = false,
          spell = false,
          statuscolumn = '',
        },
        cache = vim.fn.stdpath 'cache' .. '/snacks/image',
        debug = {
          request = false,
          convert = false,
          placement = false,
        },
        env = {},
        -- icons used to show where an inline image is located that is
        -- rendered below the text.
        icons = {
          math = '󰪚 ',
          chart = '󰄧 ',
          image = ' ',
        },
        ---@class snacks.image.convert.Config
        convert = {
          notify = true, -- show a notification on error
          ---@type snacks.image.args
          mermaid = function()
            local theme = vim.o.background == 'light' and 'neutral' or 'dark'
            return { '-i', '{src}', '-o', '{file}', '-b', 'transparent', '-t', theme, '-s', '{scale}' }
          end,
          ---@type table<string,snacks.image.args>
          magick = {
            default = { '{src}[0]', '-scale', '1920x1080>' }, -- default for raster images
            vector = { '-density', 192, '{src}[0]' }, -- used by vector images like svg
            math = { '-density', 192, '{src}[0]', '-trim' },
            pdf = { '-density', 192, '{src}[0]', '-background', 'white', '-alpha', 'remove', '-trim' },
          },
        },
      },
      notifier = { enabled = true },
      input = { enabled = true },
      statuscolumn = { enabled = true },
      dim = {
        enabled = true,
        config = function()
          DIM_ENABLE = false
        end,
      },
      words = { enabled = true },
      indent = { enabled = true },
      toggle = {},
    },
    keys = {
      {
        '<leader>.',
        function()
          Snacks.scratch()
        end,
        desc = 'Toggle Scratch Buffer',
      },
      {
        '<leader>S',
        function()
          Snacks.scratch.select()
        end,
        desc = 'Select Scratch Buffer',
      },
      {
        '<leader>gB',
        function()
          Snacks.gitbrowse()
        end,
        desc = 'Git Browse',
      },
      {
        '<leader>hh',
        function()
          Snacks.notifier.show_history()
        end,
        desc = 'Show [h]istory',
      },
      {
        '<lader>dd',
        function()
          Snacks.toggle.dim()
        end,
        desc = '[d]im some stuff',
      },
      {
        '<leader>ww',
        function()
          Snacks.words.jump(1, true)
        end,
        desc = 'show [w]ords',
      },
      {
        '<leader>xd',
        function()
          Snacks.toggle.diagnostics()
        end,
        desc = '[t]oggle [d]iagnostics',
      },
    },
  },
}
