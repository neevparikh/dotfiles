" Vim syntax file
" Language: todo
" Maintainer: Neev Parikh
" Latest Revision: 2022-11-28

if exists("b:current_syntax") 
  finish
endif

syn match fluff "|\|+[-]*+"
syn match topic "(\w*)"
syn keyword title TODO

syn match basic "^[-]"
syn match done "^[x]"
syn match imp "^[!]"
syn match markers "^[\*\.]"

let b:current_syntax = "todo"

hi def link title Title
hi def link fluff Comment

hi def link topic StorageClass

hi def link imp WarningMsg
hi def link basic Statement
hi def link done Identifier

hi def link markers Constant
