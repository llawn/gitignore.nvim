--- Storage: files kept on disk in one directory.

---@class gitignore.Cache
---@field read fun(file: string): string? Content of a stored file, if any
---@field write fun(file: string, content: string) Store a file
---@field age fun(file: string): number? Seconds since the file was stored, if it is
---@field files fun(pattern: string): string[] Names of the stored files matching a glob

local M = {}

---@param dir string
---@return gitignore.Cache
function M.new(dir)
  local function path(file)
    return dir .. "/" .. file
  end

  return {
    read = function(file)
      if vim.fn.filereadable(path(file)) == 0 then
        return nil
      end
      return table.concat(vim.fn.readfile(path(file)), "\n")
    end,

    write = function(file, content)
      vim.fn.mkdir(dir, "p")
      local f = io.open(path(file), "w")
      if f then
        f:write(content)
        f:close()
      end
    end,

    age = function(file)
      local stat = vim.uv.fs_stat(path(file))
      return stat and os.time() - stat.mtime.sec or nil
    end,

    files = function(pattern)
      return vim.tbl_map(function(found)
        return vim.fn.fnamemodify(found, ":t")
      end, vim.fn.glob(path(pattern), false, true))
    end,
  }
end

return M
