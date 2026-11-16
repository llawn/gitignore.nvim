# gitignore.nvim

Pick a `.gitignore` template from the official [github/gitignore](https://github.com/github/gitignore)
repository and append it to your project's `.gitignore`.

A minimal, dependency-free take on
[telescope-gitignore.nvim](https://github.com/llawn/telescope-gitignore.nvim): the picker is `vim.ui.select`

- No plugin dependencies
- Never blocks Neovim while fetching
- The template list and downloaded templates are cached for a week (configurable), and still available offline

## Requirements

- Neovim 0.10+
- `curl`

## Install

```lua
-- Neovim 0.12+ (vim.pack)
vim.pack.add({ "https://github.com/llawn/gitignore.nvim" })

-- lazy.nvim
{ "llawn/gitignore.nvim" }
```

## Usage

Run `:Gitignore`, pick a template, and it is appended to `.gitignore` in the current directory.

```lua
vim.keymap.set("n", "<leader>gi", require("gitignore").open, { desc = "Gitignore templates" })
```

## Configuration

Calling `setup` is optional. These are the defaults:

```lua
require("gitignore").setup({
  cache_dir = vim.fn.stdpath("data") .. "/gitignore",
  api_url = "https://api.github.com/repos/github/gitignore/contents/",
  -- Seconds before cached data is outdated and downloaded again.
  -- 0 always downloads, math.huge never refreshes.
  max_age = 7 * 24 * 60 * 60,
  -- Defaults to appending the template to ./.gitignore
  on_select = function(name, content) end,
})
```
