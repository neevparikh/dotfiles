-- vim: set foldmethod=marker:foldlevel=0
require("helpers")

function SwitchTheme()
  local cur = vim.opt.background:get()
  if cur == "dark" then
    vim.opt.background = "light"
    vim.fn.system("toggle-theme --light")
  else
    vim.opt.background = "dark"
    vim.fn.system("toggle-theme --dark")
  end
end

function CheckTheme()
  local theme = ReadFile(os.getenv("HOME") .. "/.config/theme.yml")
  if theme == nil then
    return "dark"
  else
    return theme:gsub("\n", "")
  end
end

vim.cmd("colorscheme gruvbox")
vim.g.gruvbox_contrast_light = "medium"
vim.g.gruvbox_contrast_dark = "hard"
vim.opt.background = CheckTheme()
vim.api.nvim_set_hl(0, "FloatBorder", { link = "GruvboxBg2" })
