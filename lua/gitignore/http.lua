--- Transport: fetch a URL without blocking Neovim.

---@class gitignore.Http
---@field get fun(url: string, callback: fun(body?: string)) `callback` gets nil on any failure
local M = {}

function M.get(url, callback)
  if vim.fn.executable("curl") == 0 then
    return callback(nil)
  end
  vim.system(
    { "curl", "-fsSL", "--connect-timeout", "5", url },
    { text = true },
    vim.schedule_wrap(function(res)
      callback(res.code == 0 and res.stdout or nil)
    end)
  )
end

return M
