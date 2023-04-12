-- vim: set foldmethod=marker:
-- {{{ import
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
-- }}}


return {}, {
  s({ trig = '+', dscr = "notes item", snippetType = 'autosnippet' },
    fmt([[+ {} 
  * {}]], { i(1, 'topic'), i(2, 'content') })
  ),
  s({ trig = '-', dscr = "quick todo item", snippetType = 'autosnippet' },
    fmt("- ({}) {}", { i(1, 'topic'), i(2, 'content') })
  ),
  s({ trig = '#', dscr = "seperator", snippetType = 'autosnippet' },
    fmt("- ({}) ------------------------------------------------------------------------------------------",
      { i(1, 'topic') })
  ),
  s({ trig = 'tdi', dscr = "full todo item", snippetType = 'autosnippet' },
    fmt("- | ({}/{}) | 0{}.{} hrs | ({}) {}", { i(1), i(2), i(3), i(4, '0'), i(5), i(6) })
  ),
}
