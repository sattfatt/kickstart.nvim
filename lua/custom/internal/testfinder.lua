local M = {}

-- Function to get the name of the nearest Go test function
function M.get_nearest_test_name()
  -- Ensure we're in a Go file
  if vim.bo.filetype ~= 'go' then
    vim.notify('Not in a Go file', vim.log.levels.ERROR)
    return nil
  end

  -- Get current buffer and cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1 -- Convert to 0-based index

  -- Get Treesitter parser and tree
  local parser = vim.treesitter.get_parser(bufnr, 'go')
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Query to find test function names
  local query = vim.treesitter.query.parse(
    'go',
    [[
        (function_declaration
            name: (identifier) @func_name
            (#match? @func_name "^Test")
        )
    ]]
  )

  -- Variables to track the nearest test
  local nearest_test_name = nil
  local min_distance = math.huge

  -- Iterate through all matches
  for id, node, metadata in query:iter_captures(root, bufnr, 0, -1) do
    local start_row = node:range()
    local test_name = vim.treesitter.get_node_text(node, bufnr)

    -- Calculate distance to current cursor
    local distance = math.abs(row - start_row)

    -- Update if this is the nearest test so far
    if distance < min_distance then
      min_distance = distance
      nearest_test_name = test_name
    end
  end

  return nearest_test_name
end

-- Function to get the current test that the cursor is inside
function M.get_current_test_name()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1
  local col = cursor_pos[2]

  -- Ensure we have a parser for Go
  local lang_tree = vim.treesitter.get_parser(bufnr, 'go')
  if not lang_tree then
    return nil
  end

  -- Get the syntax tree
  local syntax_tree = lang_tree:parse()
  if not syntax_tree or not syntax_tree[1] then
    return nil
  end

  local root = syntax_tree[1]:root()
  if not root then
    return nil
  end

  -- Find the node at cursor
  local node = root:descendant_for_range(row, col, row, col)
  if not node then
    return nil
  end

  -- Walk up the tree to find the function declaration
  while node do
    print('node:', node)
    if node:type() == 'function_declaration' then
      -- Get function name node which is a child of function_declaration
      for child in node:iter_children() do
        if child:type() == 'identifier' then
          local name = vim.treesitter.get_node_text(child, bufnr)
          -- Only return if it's a test function
          if name:match '^Test' then
            return name
          end
        end
      end
    end
    node = node:parent()
  end

  return nil
end

function M.get_test_name()
  -- first try to get the test the cursor is on
  local current_test = M.get_current_test_name()
  -- if not found, try to get the nearest test
  if not current_test then
    current_test = M.get_nearest_test_name()
  end

  return current_test
end

return M
