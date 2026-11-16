--- Repository: where templates come from. Knows nothing about curl or the
--- filesystem; it only talks to the `http` and `cache` it is given.
---
--- Both the template list and each template are cached. A cached entry is
--- used as is until it is older than `max_age`; then it is downloaded again,
--- and the outdated copy is only used if that download fails.

---@class gitignore.Template
---@field name string Template name, e.g. "Python"
---@field url? string Download URL; nil when the list comes from the cache

---@class gitignore.Templates
---@field list fun(callback: fun(templates: gitignore.Template[], offline: boolean))
---@field content fun(template: gitignore.Template, callback: fun(content?: string))

---@class gitignore.TemplatesDeps
---@field api_url string GitHub contents API URL listing the templates
---@field max_age number Seconds before a cached entry is outdated
---@field http gitignore.Http
---@field cache gitignore.Cache

local M = {}

local INDEX = "index.json"
local EXT = ".gitignore"

--- Turn the GitHub contents API response into templates; nil if it is not one.
---@param body? string
---@return gitignore.Template[]?
local function parse(body)
  local ok, files = pcall(vim.json.decode, body or "")
  if not ok or type(files) ~= "table" then
    return nil
  end

  local templates = {}
  for _, file in ipairs(files) do
    local name = type(file.name) == "string" and file.name:match("^(.+)%.gitignore$")
    if name then
      table.insert(templates, { name = name, url = file.download_url })
    end
  end
  return templates
end

---@param deps gitignore.TemplatesDeps
---@return gitignore.Templates
function M.new(deps)
  local http, cache = deps.http, deps.cache

  ---@param file string
  ---@return boolean
  local function fresh(file)
    local age = cache.age(file)
    return age ~= nil and age < deps.max_age
  end

  --- Templates already downloaded, for when the list itself is unreachable.
  ---@return gitignore.Template[]
  local function downloaded()
    return vim.tbl_map(function(file)
      return { name = file:sub(1, -#EXT - 1) }
    end, cache.files("*" .. EXT))
  end

  return {
    list = function(callback)
      local cached = fresh(INDEX) and parse(cache.read(INDEX))
      if cached then
        return callback(cached, false)
      end

      http.get(deps.api_url, function(body)
        local online = parse(body)
        if online then
          cache.write(INDEX, body)
          return callback(online, false)
        end
        callback(downloaded(), true)
      end)
    end,

    content = function(template, callback)
      local file = template.name .. EXT
      local cached = cache.read(file)
      if not template.url or (cached and fresh(file)) then
        return callback(cached)
      end

      http.get(template.url, function(body)
        if body then
          cache.write(file, body)
        end
        callback(body or cached)
      end)
    end,
  }
end

return M
