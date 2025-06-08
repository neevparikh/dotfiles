require("io")
require("helpers")

local output = vim.tbl_map(MergeWithLink, {
  NormalFloat = { link = "Normal" },
  SignColumn = { link = "Normal" },

  String = { italic = false },
  -- TODO: update this to use get_colors when exposed
  ["@text.todo.comment"] = { link = "htmlBoldItalic" },
  ["@text.danger.comment"] = { link = "htmlBoldItalic" },
  -- lua_ls defines comment semantic group, overrides other comment-specific things
  ["@lsp.type.comment.lua"] = {},

  -- FIXME: find a better solution for this, maybe a plugin or something
  -- diffAdded = { fg = "#98971a" },
  -- diffRemoved = { fg = "#cc241d" },
  diffAdded = { link = "DiffAdd", bg = "bg" },
  diffRemoved = { link = "DiffDelete", bg = "bg" },

  AvanteConflictCurrentLabel = { link = "DiffDelete" },
  AvanteConflictCurrent = { link = "DiffDelete", bold = true },
  AvanteConflictIncomingLabel = { link = "DiffAdd" },
  AvanteConflictIncoming = { link = "DiffAdd", bold = true },

  FloatBorder = { link = "GruvboxBg2" },

  TelescopeBorder = { link = "GruvboxBg2" },
  TelescopePromptBorder = { link = "GruvboxBg2" },
  TelescopeResultsBorder = { link = "GruvboxBg2" },
  TelescopePreviewBorder = { link = "GruvboxBg2" },

  FzfLuaBorder = { link = "GruvboxBg2" },
  FzfLuaFzfBorder = { link = "GruvboxBg2" },
  FzfLuaPreviewBorder = { link = "GruvboxBg2" },

  MasonNormal = { link = "GruvboxFg1" },
  MasonMutedBlock = { link = "GruvboxRed" },
  MasonMutedBlockBold = { link = "GruvboxRed", bold = true },
  MasonHighlight = { link = "GruvboxOrange" },
  MasonHighlightBlock = { link = "GruvboxOrangeBold" },
  MasonHighlightBlockBold = { link = "GruvboxOrangeBold", bold = true },
  MasonHighlightSecondary = { link = "GruvboxYellow" },
  MasonHighlightBlockSecondary = { link = "GruvboxYellow" },
  MasonHighlightBlockBoldSecondary = { link = "GruvboxYellow", bold = true },
})

local file = io.open("table.txt", "w")
file:write(vim.inspect(output))
file:close()
