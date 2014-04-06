" Vim global plugin for Pocket Brows
" Maintainer: Yudai Tsuyuzaki <soramugi.chika@gmail.com>
" License: This file is placed in the public domain.

if exists("g:autoloaded_pocket")
  finish
endif
let g:autoloaded_pocket = 1

let s:save_cpo = &cpo
set cpo&vim

"------------------------
" setting
"------------------------
if !exists("g:pocket_list_count")
  let g:pocket_list_count = 50
endif

"------------------------
" function
"------------------------
function! pocket#list()
  cclose
  let temp_errorfomat = &errorformat
  let url = 'https://getpocket.com/v3/get'
  let ctx = pocket#conf()
  let ctx.count = g:pocket_list_count
  let ctx.sort = 'newest'

  try
    let res = webapi#http#post(url, ctx, {})

    let obj = webapi#json#decode(res.content)
    let lists = []
    for key in keys(obj.list)
      let item = obj.list[key]
      let lists += [
            \item.given_title,
            \[item.given_url],
            \key,
            \]
    endfor
    let &errorformat = '%A[%f],%Z%l,%C%m'
    cgetexpr join(lists,"\n")
    copen 50
  catch
    echo v:exception
    echo v:throwpoint
  finally
    let &errorformat = temp_errorfomat
  endtry
endfunction

function! pocket#send(action)
  let matched = matchlist(getline('.'), '|\(\d\+\)|')
  if !empty(matched)
    let item_id = matched[1]
  endif
  if empty(matched) || item_id == ''
    echo 'not search item_id'
    return
  endif
  let url = 'https://getpocket.com/v3/send'
  let ctx = pocket#conf()
  let ctx.actions = pocket#action_parse(a:action, item_id)
  let res = webapi#http#get(url, ctx)
  if res.status =~ '200'
    echo a:action . ' item ' . item_id
  else
    echo 'error ' . a:action . ' item ' . item_id . ' message : '. res.content
  endif
  if 'archive' == a:action
    silent call pocket#list()
  endif
endfunction

function! pocket#action_parse(action,item_id)
  return '[{"action":"' . a:action . '","item_id":"' . a:item_id . '"}]'
endfunction

function! pocket#conf()
  let ctx = {}
  let configfile = expand('~/.pocket-vim')
  if filereadable(configfile)
    let ctx = eval(join(readfile(configfile), ""))
  else
    let ctx.consumer_key = input("consumer_key:")
    let ctx.access_token = input("access_token:")

    call writefile([string(ctx)], configfile)
  endif
  return ctx
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
