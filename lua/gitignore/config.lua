--- User options.

---@class gitignore.Config
---@field cache_dir string Where downloaded templates are kept for offline use
---@field api_url string GitHub contents API URL listing the templates
---@field max_age number Seconds before cached data is outdated and downloaded again (0: always download)
---@field on_select gitignore.Action Called with the chosen template
local defaults = {
  cache_dir = vim.fn.stdpath("data") .. "/gitignore",
  api_url = "https://api.github.com/repos/github/gitignore/contents/",
  max_age = 7 * 24 * 60 * 60, -- one week
  on_select = require("gitignore.actions").append,
}

local M = {}

---@type gitignore.Config
M.options = defaults

---@param opts? gitignore.Config|{}
function M.setup(opts)
  M.options = vim.tbl_extend("force", defaults, opts or {})
end

return M
