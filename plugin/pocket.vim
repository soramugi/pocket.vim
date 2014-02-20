" Vim global plugin for Pocket Brows
" Last Change: 2014 Feb 20
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:loaded_pocket")
  finish
endif
let g:loaded_pocket = 1

let s:save_cpo = &cpo
set cpo&vim
set rtp+=webapi-vim

command! -nargs=0 PocketList call pocket#list()
command! -nargs=0 PocketArchive call pocket#send('archive')
command! -nargs=0 PocketFavorite call pocket#send('favorite')

let &cpo = s:save_cpo
unlet s:save_cpo
