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
syn keyword title NOTES

syn match basic "\v^[-]"
syn match done "\v^[x]"
syn match imp "\v^[!]"
syn match markers "\v^\s*\*"
syn match period_markers "\v^\s*\."
syn match notes_markers "\v^\+\s"

syn match seperator "\v----*--"

let b:current_syntax = "todo"

hi def link title Title
hi def link fluff Comment
hi def link seperator Comment

hi def link topic StorageClass

hi def link imp WarningMsg
hi def link basic Statement
hi def link done Identifier

hi def link markers Constant
hi def link period_markers Constant
hi def link notes_markers Statement
