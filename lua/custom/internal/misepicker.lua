local M = {}

local function setup_highlights()
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

  -- Convert tasks to picker items
  local items = {}
  for _, task in ipairs(tasks) do
    -- Build location string
    local location_str = ''
    if task.dir and task.dir == vim.NIL then
      location_str = ' [N/A]'
    elseif task.dir and task.dir ~= '' then
      location_str = ' [' .. task.dir .. ']'
    end

    table.insert(items, {
      text = task.name .. location_str .. ' ' .. (task.description or ''), -- searchable text
      name = task.name,
      location = location_str,
      description = task.description or '',
      task = task, -- store original task data
    })
  end

  local term_ok, terminal_module = pcall(require, 'toggleterm.terminal')
  local Terminal = term_ok and terminal_module.Terminal or nil

  Snacks.picker {
    title = 'Mise Tasks',
    layout = { preset = 'default', preview = true },
    items = items,
    matcher = {
      field = 'text', -- Only search the text field (task name)
    },

    format = function(item, _)
      return {
        { item.name, 'MiseTaskName' },
        { ' |', 'MiseTaskSeparator' },
        { item.location, 'MiseTaskLocation' },
        { ' | ', 'MiseTaskSeparator' },
        { item.description, 'MiseTaskDescription' },
      }
    end,

    preview = function(ctx)
      if not ctx.item or not ctx.item.task then
        local lines = {
          '# No task selected',
          '',
          'Please select a task to view details.',
        }
        vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
        vim.bo[ctx.buf].filetype = 'markdown'
        return true
      end

      local task = ctx.item.task

      local function get_cmd_string(cmd)
        if type(cmd) == 'table' then
          return table.concat(cmd, ' ')
        elseif type(cmd) == 'string' then
          return cmd
        end
        return 'N/A'
      end

      local function formatted(input)
        if input == vim.NIL then
          return 'N/A'
        end
        if input == nil or input == '' then
          return 'N/A'
        end
        return tostring(input)
      end

      local cmd = task.run or task.command
      local cmd_str = get_cmd_string(cmd)

      local lines = {
        '# Task Details',
        '',
        '## Name',
        formatted(task.name),
        '',
        '## Source',
        formatted(task.source),
        '',
        '## Directory',
        formatted(task.dir),
        '',
        '## Description',
        formatted(task.description),
        '',
        '## Command',
        '```bash',
        cmd_str,
        '```',
      }

      vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, lines)
      vim.bo[ctx.buf].filetype = 'markdown'
      -- vim.bo[ctx.buf].modifiable = false
      -- vim.bo[ctx.buf].buftype = 'nofile'

      return true
    end,

    actions = {
      run_task = function(picker)
        if not Terminal then
          vim.notify('toggleterm.nvim Terminal class not found. Is it installed and updated?', vim.log.levels.ERROR)
          return
        end

        local item = picker:current()
        if not item then
          return
        end
        local task = item.task

        picker:close()

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
            vim.schedule(function()
              M.running_tasks[task.name] = nil
              local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
              vim.notify('Task "' .. task.name .. '" finished (code: ' .. exit_code .. ')', level)
            end)
          end,
        }

        term:open(get_term_size(), 'vertical')
        M.running_tasks[task.name] = term
      end,

      edit_source = function(picker)
        local item = picker:current()
        if not item then
          return
        end
        local task = item.task
        local source_path = task.source

        if not source_path or source_path == '' then
          vim.notify('No source file specified for this task', vim.log.levels.WARN)
          return
        end

        picker:close()
        vim.cmd('edit ' .. vim.fn.fnameescape(source_path))

        -- Try to jump to the task definition
        local toml_pattern = '\\V[tasks.' .. task.name .. ']'
        local json_pattern = '\\V"' .. task.name .. '":'

        local line_num = vim.fn.search(toml_pattern, 'Wc')

        if line_num == 0 then
          line_num = vim.fn.search(json_pattern, 'Wc')
        end

        if line_num == 0 then
          vim.fn.cursor(1, 1)
          line_num = vim.fn.search('\\V' .. task.name, 'Wc')
        end

        if line_num == 0 then
          vim.notify('Opened ' .. source_path .. '. Could not find definition for ' .. task.name, vim.log.levels.INFO)
        end
      end,
    },

    win = {
      input = {
        keys = {
          ['<CR>'] = { 'run_task', mode = { 'n', 'i' }, desc = 'Run Task' },
          ['<C-e>'] = { 'edit_source', mode = { 'n', 'i' }, desc = 'Edit Task Source' },
        },
      },
    },

    confirm = function(picker, item)
      if not Terminal then
        vim.notify('toggleterm.nvim Terminal class not found. Is it installed and updated?', vim.log.levels.ERROR)
        return
      end

      if not item then
        return
      end
      local task = item.task

      picker:close()

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
          vim.schedule(function()
            M.running_tasks[task.name] = nil
            local level = exit_code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
            vim.notify('Task "' .. task.name .. '" finished (code: ' .. exit_code .. ')', level)
          end)
        end,
      }

      term:open(get_term_size(), 'vertical')
      M.running_tasks[task.name] = term
    end,
  }
end

return M
