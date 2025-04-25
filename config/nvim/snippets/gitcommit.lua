-- vim: set foldmethod=marker:
-- {{{ import
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
-- }}}

local function formatConventionalSnippet(name)
  return s({
    trig = name,
    dscr = name .. " convention commit",
    snippetType = "autosnippet",
    condition = function(line_to_cursor, _, _)
      return line_to_cursor == ""
    end,
  }, {
    t(name .. ": "),
    i(0),
  })
end

return {}, {
  formatConventionalSnippet("feat"),
  formatConventionalSnippet("chore"),
  formatConventionalSnippet("wip"),
  formatConventionalSnippet("fix"),
  formatConventionalSnippet("docs"),
  formatConventionalSnippet("build"),
  formatConventionalSnippet("style"),
  formatConventionalSnippet("nit"),
  formatConventionalSnippet("lint"),
  formatConventionalSnippet("ci"),
  formatConventionalSnippet("test"),
  formatConventionalSnippet("perf"),
  formatConventionalSnippet("refactor"),
  formatConventionalSnippet("BREAK"),
}
