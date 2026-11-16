--- Entry point: wires the parts together and drives the picker.
local config = require("gitignore.config")

local M = {}

M.setup = config.setup

--- Let the user choose a template, then hand its content to `on_select`.
---@param templates gitignore.Templates
---@param on_select gitignore.Action
local function pick(templates, on_select)
  templates.list(function(items, offline)
    if #items == 0 then
      return vim.notify("gitignore: no templates found", vim.log.levels.ERROR)
    end

    vim.ui.select(items, {
      prompt = offline and "Gitignore templates (offline)" or "Gitignore templates",
      format_item = function(template)
        return template.name
      end,
    }, function(template)
      if not template then
        return
      end
      templates.content(template, function(content)
        if not content then
          return vim.notify("gitignore: unable to load " .. template.name, vim.log.levels.ERROR)
        end
        on_select(template.name, content)
      end)
    end)
  end)
end

--- Pick a template with `vim.ui.select`.
function M.open()
  local opts = config.options
  local templates = require("gitignore.templates").new({
    api_url = opts.api_url,
    max_age = opts.max_age,
    http = require("gitignore.http"),
    cache = require("gitignore.cache").new(opts.cache_dir),
  })
  pick(templates, opts.on_select)
end

return M
