local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local M = {}

-- Function to execute your binary and get results
local function get_binary_output()
  -- Replace 'your_binary' with actual binary name
  local handle = io.popen 'dt h wf'
  local result = ''
  if handle then
    result = handle:read '*a'
    handle:close()
  end
  return vim.split(result, '\n')
end

-- Function to pipe selected item to second binary
local function pipe_to_binary(selected_item)
  -- Replace 'second_binary' with actual binary name
  local command = string.format("dt wf '%s'", selected_item)
  vim.fn.system(command)
end

-- Create custom picker
M.custom_picker = function(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = 'Binary Output Picker',
      finder = finders.new_table {
        results = get_binary_output(),
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        -- Define custom action on selection
        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          -- Pipe selected item to second binary
          pipe_to_binary(selection[1])
        end)

        return true
      end,
    })
    :find()
end

return M
