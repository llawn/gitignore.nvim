--- What can be done with a selected template.

---@alias gitignore.Action fun(name: string, content: string)

local M = {}

--- Append the template to the `.gitignore` of the current directory.
---@type gitignore.Action
function M.append(name, content)
  local f = io.open(vim.fn.getcwd() .. "/.gitignore", "a")
  if not f then
    return vim.notify("gitignore: unable to write .gitignore", vim.log.levels.ERROR)
  end
  f:write(("\n# --- %s ---\n%s\n"):format(name, content))
  f:close()
  vim.cmd.checktime()
  vim.notify("gitignore: added " .. name)
end

return M
