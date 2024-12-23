local M = {}

function M.get_current_test()
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
  local node = root:descendant_for_range(row, row, col, col)
  if not node then
    return nil
  end

  -- Walk up the tree to find the function declaration
  while node do
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

return M
