-- vim: set foldmethod=marker:
-- {{{ import
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
-- }}}

local function makeAsComment(_, _, str)
  return vim.opt.commentstring:get():gsub("%%s", str)
end

return {}, {
  s({ trig = "--{", dscr = "Fold Marker", snippetType = "autosnippet" }, {
    f(makeAsComment, {}, { user_args = { "{{{ " } }),
    d(1, function(_, parent, _, _)
      if next(parent.env.TM_SELECTED_TEXT) == nil then
        return sn(
          nil,
          fmt("{}\n{}", {
            i(1, "label"),
            i(2, ""),
          })
        )
      else
        return sn(
          nil,
          fmt("{}\n{selected}", {
            i(1, "label"),
            selected = t(parent.env.TM_SELECTED_TEXT),
          })
        )
      end
    end),
    t({ "", "" }),
    f(makeAsComment, {}, { user_args = { "}}}" } }),
    i(0),
  }),
}
