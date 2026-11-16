if vim.g.loaded_gitignore == 1 then
  return
end
vim.g.loaded_gitignore = 1

vim.api.nvim_create_user_command("Gitignore", function()
  require("gitignore").open()
end, { desc = "Pick a gitignore template" })
