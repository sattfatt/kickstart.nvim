local M = {}

local function setup_highlights()
  vim.notify 'loading Mise highlights...'
  vim.api.nvim_set_hl(0, 'MiseTaskName', { link = 'Constant' })
  vim.api.nvim_set_hl(0, 'MiseTaskLocation', { link = 'Directory' })
  vim.api.nvim_set_hl(0, 'MiseTaskSeparator', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'MiseTaskDescription', { link = 'String' })
end

vim.api.nvim_create_augroup('MisePickerHighlights', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = 'MisePickerHighlights',
  pattern = '*',
  callback = function()
    setup_highlights()
  end,
})

setup_highlights()

M.running_tasks = {}

M.pick_tasks = function(opts)
  opts = opts or {}
  local handle = io.popen 'mise tasks ls --json 2>/dev/null'
  local result = handle:read '*a'
  handle:close()

  local ok, tasks = pcall(vim.json.decode, result)
  if not ok or not tasks then
    vim.notify('No mise tasks found', vim.log.levels.WARN)
    return
  end

  require('telescope.pickers')
    .new(opts, {
      prompt_title = 'Mise Tasks',
      finder = require('telescope.finders').new_table {
        results = tasks,

        entry_maker = function(task)
          local hl_name = 'MiseTaskName'
          local hl_location = 'MiseTaskLocation'
          local hl_separator = 'MiseTaskSeparator'
          local hl_description = 'MiseTaskDescription'

          -- 2. Build display string parts
          local name_str = task.name
          local sep_1_str = ' |'
          local location_str = ''
          if task.dir and task.dir == vim.NIL then
            location_str = string.format(' [%s]', 'N/A')
          elseif task.dir and task.dir ~= '' then
            location_str = string.format(' [%s]', task.dir)
          end
          local separator_str = ' | '
          local description_str = task.description or ''

          local display_str = name_str .. sep_1_str .. location_str .. separator_str .. description_str

          -- 3. Calculate byte positions
          -- This is a more direct way to calculate byte offsets
          local highlights = {}
          local len_name = #name_str
          local len_loc = #location_str
          local len_1_sep = #sep_1_str
          local len_sep = #separator_str
          local len_desc = #description_str

          if len_name > 0 then
            table.insert(highlights, { { 0, len_name }, hl_name })
          end
          if len_sep > 0 then
            table.insert(highlights, { { len_name, len_name + len_1_sep }, hl_separator })
          end
          if len_loc > 0 then
            table.insert(highlights, { { len_name + len_1_sep, len_name + len_1_sep + len_loc }, hl_location })
          end
          if len_sep > 0 then
            table.insert(highlights, { { len_name + len_1_sep + len_loc, len_name + len_1_sep + len_loc + len_sep }, hl_separator })
          end
          if len_desc > 0 then
            table.insert(highlights, { { len_name + len_1_sep + len_loc + len_sep, len_name + len_1_sep + len_loc + len_sep + len_desc }, hl_description })
          end

          local ent = require('telescope.make_entry').set_default_entry_mt {
            value = task,
            ordinal = task.name,
            display = function()
              return display_str, highlights
            end,
          }

          return ent
        end,
      },
      sorter = require('telescope.config').values.generic_sorter(opts),
      previewer = require('telescope.previewers').new_buffer_previewer {
        define_preview = function(self, entry)
          local task = entry.value
          local cmd = task.run or task.command
          local function get_cmd_string(cmd)
            if type(cmd) == 'table' then
              return table.concat(cmd, ' ') -- Join array with spaces
            elseif type(cmd) == 'string' then
              return cmd
            end
            return 'N/A' -- Default if nil or other type
          end

          local function formatted(input)
            if input == vim.NIL then
              return ''
            end
            return input
          end

          local template = [[ # Task Details

## Name
%s

## Source
%s

## Directory
%s

# Description
%s

# Command
``` bash
%s

```
            ]]

          local hydrated =
            string.format(template, formatted(task.name), formatted(task.source), formatted(task.dir), formatted(task.description), get_cmd_string(cmd))

          local lines = vim.split(hydrated, '\n')

          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
          vim.api.nvim_set_option_value('filetype', 'markdown', { buf = self.state.bufnr })
          vim.api.nvim_set_option_value('wrap', true, { win = self.state.winid })
          vim.api.nvim_set_option_value('linebreak', true, { win = self.state.winid })
          vim.api.nvim_buf_call(self.state.bufnr, function()
            vim.api.nvim_command 'RenderMarkdown'
          end)
        end,
      },
      attach_mappings = function(prompt_bufnr, map)
        local actions = require 'telescope.actions'
        local action_state = require 'telescope.actions.state'

        local term_ok, terminal_module = pcall(require, 'toggleterm.terminal')
        local Terminal = term_ok and terminal_module.Terminal or nil

        map('i', '<CR>', function(bufnr)
          if not Terminal then
            vim.notify('toggleterm.nvim Terminal class not found. Is it installed and updated?', vim.log.levels.ERROR)
            return
          end

          local entry = action_state.get_selected_entry()
          if not entry then
            return
          end
          local task = entry.value

          actions.close(bufnr)

          local function get_term_size()
            return math.max(40, math.floor(vim.o.columns * 0.4))
          end

          if M.running_tasks[task.name] then
            M.running_tasks[task.name]:open(get_term_size(), 'vertical')
            vim.notify('Task "' .. task.name .. '" is already running. Focusing.', vim.log.levels.INFO)
            return
          end

          local cmd_to_run = 'mise run ' .. task.name
          local run_dir = task.dir or vim.fn.getcwd()

          -- 5. Create a new toggleterm.Terminal object
          local term = Terminal:new {
            cmd = cmd_to_run,
            cwd = run_dir,
            close_on_exit = false,
            on_open = function(t)
              vim.schedule(function()
                vim.cmd 'startinsert'
              end)
            end,
            on_exit = function(t, job_id, exit_code)
              -- This callback fires when the *process* (e.g., Go server)
              -- actually exits or is killed.
              vim.schedule(function()
                M.running_tasks[task.name] = nil -- Remove from running list
                local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
                vim.notify('Task "' .. task.name .. '" finished (code: ' .. exit_code .. ')', level)
              end)
            end,
          }

          -- 6. Open the terminal and store it in our cache
          term:open(get_term_size(), 'vertical')

          M.running_tasks[task.name] = term
        end)

        local function edit_task_source(bufnr)
          local entry = action_state.get_selected_entry()
          if not entry then
            return
          end
          local task = entry.value
          local source_path = task.source

          if not source_path or source_path == '' then
            vim.notify('No source file specified for this task', vim.log.levels.WARN)
            return
          end

          -- Close telescope *before* editing the file
          actions.close(bufnr)
          -- Use fnameescape to handle paths with spaces or special chars
          vim.cmd('edit ' .. vim.fn.fnameescape(source_path))

          -- NEW: Try to jump to the task definition
          -- Use '\V' (very nomagic) for literal search
          local toml_pattern = '\\V[tasks.' .. task.name .. ']'
          local json_pattern = '\\V"' .. task.name .. '":'

          -- 'Wc' = Don't wrap search, 'c' = move cursor
          local line_num = vim.fn.search(toml_pattern, 'Wc')

          -- If TOML pattern not found, try JSON pattern
          if line_num == 0 then
            line_num = vim.fn.search(json_pattern, 'Wc')
          end

          -- If both patterns fail, fallback to a literal search for the name
          if line_num == 0 then
            vim.fn.cursor(1, 1) -- Reset cursor to top
            line_num = vim.fn.search('\\V' .. task.name, 'Wc')
          end

          if line_num == 0 then
            -- If still not found, just notify
            vim.notify('Opened ' .. source_path .. '. Could not find definition for ' .. task.name, vim.log.levels.INFO)
          end
        end

        map('n', '<C-e>', edit_task_source)
        map('i', '<C-e>', edit_task_source)

        map('i', '<C-c>', actions.close)
        map('n', '<C-c>', actions.close)
        map('n', 'q', actions.close)

        return true
      end,
    })
    :find()
end
return M
