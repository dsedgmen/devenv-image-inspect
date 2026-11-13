" autoload/image_inspect.vim — Vim frontend for devenv-image-inspect CLI
if exists('g:autoloaded_image_inspect')
  finish
endif
let g:autoloaded_image_inspect = 1

function! s:cli() abort
  if exists('g:image_inspect_cli') && !empty(g:image_inspect_cli)
    return g:image_inspect_cli
  endif
  let l:candidates = []
  if exists('$DEVENV_IMAGE_INSPECT_DIR') && !empty($DEVENV_IMAGE_INSPECT_DIR)
    call add(l:candidates, $DEVENV_IMAGE_INSPECT_DIR . '/bin/devenv-image-inspect')
  endif
  call add(l:candidates, expand('<sfile>:p:h:h') . '/bin/devenv-image-inspect')
  call add(l:candidates, expand('~/.local/bin/devenv-image-inspect'))
  call add(l:candidates, '/usr/bin/devenv-image-inspect')
  for l:c in l:candidates
    if executable(l:c)
      return l:c
    endif
  endfor
  if executable('devenv-image-inspect')
    return 'devenv-image-inspect'
  endif
  return ''
endfunction

function! s:shellesc(s) abort
  return shellescape(a:s, 1)
endfunction

function! image_inspect#resolve_ref(...) abort
  if a:0 >= 1 && !empty(a:1)
    return a:1
  endif
  let l:cword = expand('<cWORD>')
  if l:cword =~# '^[A-Za-z0-9._/-]\+:[A-Za-z0-9._-]\+$' || l:cword =~# '^[A-Za-z0-9._/-]\+$'
    if l:cword !~# '^[./]'
      return l:cword
    endif
  endif
  let l:ref = input('Image ref: ')
  return l:ref
endfunction

function! s:run(args) abort
  let l:cli = s:cli()
  if empty(l:cli)
    echohl ErrorMsg
    echomsg 'image-inspect: devenv-image-inspect CLI not found'
    echohl None
    return []
  endif
  let l:cmd = s:shellesc(l:cli) . ' ' . a:args
  let l:out = systemlist(l:cmd)
  if v:shell_error
    echohl ErrorMsg
    echomsg 'image-inspect: ' . join(l:out, ' ')
    echohl None
    return []
  endif
  return l:out
endfunction

function! s:open_buf(name, lines, filetype) abort
  let l:name = a:name
  execute 'silent! botright new' fnameescape(l:name)
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal nowrap
  if !empty(a:filetype)
    execute 'setlocal filetype=' . a:filetype
  endif
  call setline(1, a:lines)
  setlocal nomodifiable
  nnoremap <buffer> <silent> q :close<CR>
endfunction

function! image_inspect#meta(...) abort
  let l:ref = image_inspect#resolve_ref(get(a:000, 0, ''))
  if empty(l:ref) | return | endif
  let l:lines = s:run('meta ' . s:shellesc(l:ref))
  if empty(l:lines) | return | endif
  call s:open_buf('image-meta://' . l:ref, l:lines, 'json')
endfunction

function! image_inspect#history(...) abort
  let l:ref = image_inspect#resolve_ref(get(a:000, 0, ''))
  if empty(l:ref) | return | endif
  let l:lines = s:run('history ' . s:shellesc(l:ref))
  if empty(l:lines) | return | endif
  call s:open_buf('image-history://' . l:ref, l:lines, 'dockerfile')
endfunction

function! image_inspect#inspect(...) abort
  let l:ref = image_inspect#resolve_ref(get(a:000, 0, ''))
  if empty(l:ref) | return | endif
  let l:meta = s:run('meta ' . s:shellesc(l:ref))
  if empty(l:meta) | return | endif
  let l:lines = [
        \ '# ImageInspect: ' . l:ref,
        \ '# Commands: :ImageMeta  :ImageHistory  :ImageFs  :ImageExport',
        \ '# Keys in this buffer: m=meta  h=history  f=fs  e=export  q=quit',
        \ '',
        \ ] + l:meta
  call s:open_buf('image-inspect://' . l:ref, l:lines, 'json')
  let b:image_inspect_ref = l:ref
  nnoremap <buffer> <silent> m :call image_inspect#meta(b:image_inspect_ref)<CR>
  nnoremap <buffer> <silent> h :call image_inspect#history(b:image_inspect_ref)<CR>
  nnoremap <buffer> <silent> f :call image_inspect#fs(b:image_inspect_ref, '/')<CR>
  nnoremap <buffer> <silent> e :call image_inspect#export(b:image_inspect_ref)<CR>
endfunction

function! s:parse_fs_line(line) abort
  " format: type<TAB>path
  let l:parts = split(a:line, "\t", 1)
  if len(l:parts) < 2
    return ['', '']
  endif
  return [l:parts[0], l:parts[1]]
endfunction

function! image_inspect#fs(...) abort
  let l:ref = image_inspect#resolve_ref(get(a:000, 0, ''))
  if empty(l:ref) | return | endif
  let l:path = get(a:000, 1, '/')
  if empty(l:path) | let l:path = '/' | endif
  let l:lines = s:run('fs ' . s:shellesc(l:ref) . ' ' . s:shellesc(l:path))
  if empty(l:lines) | return | endif
  let l:hdr = [
        \ '# ImageFs: ' . l:ref . '  path=' . l:path,
        \ '# <CR>=enter/open  - =parent  q=quit',
        \ '',
        \ ]
  call s:open_buf('image-fs://' . l:ref . l:path, l:hdr + l:lines, '')
  let b:image_inspect_ref = l:ref
  let b:image_inspect_path = l:path
  nnoremap <buffer> <silent> <CR> :call image_inspect#fs_enter()<CR>
  nnoremap <buffer> <silent> - :call image_inspect#fs_parent()<CR>
endfunction

function! image_inspect#fs_enter() abort
  if !exists('b:image_inspect_ref') | return | endif
  let l:line = getline('.')
  if l:line =~# '^#' || empty(l:line) | return | endif
  let [l:type, l:path] = s:parse_fs_line(l:line)
  if empty(l:path) | return | endif
  if l:type ==# 'd' || l:path =~# '/$'
    call image_inspect#fs(b:image_inspect_ref, substitute(l:path, '/$', '', ''))
  else
    let l:lines = s:run('cat ' . s:shellesc(b:image_inspect_ref) . ' ' . s:shellesc(l:path))
    if empty(l:lines) && v:shell_error | return | endif
    call s:open_buf('image-cat://' . b:image_inspect_ref . l:path, l:lines, '')
  endif
endfunction

function! image_inspect#fs_parent() abort
  if !exists('b:image_inspect_ref') || !exists('b:image_inspect_path') | return | endif
  let l:p = b:image_inspect_path
  if l:p ==# '/' | return | endif
  let l:parent = fnamemodify(substitute(l:p, '/$', '', ''), ':h')
  if empty(l:parent) | let l:parent = '/' | endif
  call image_inspect#fs(b:image_inspect_ref, l:parent)
endfunction

function! image_inspect#export(...) abort
  let l:ref = image_inspect#resolve_ref(get(a:000, 0, ''))
  if empty(l:ref) | return | endif
  let l:outdir = get(a:000, 1, '')
  let l:args = 'export ' . s:shellesc(l:ref)
  if !empty(l:outdir)
    let l:args .= ' ' . s:shellesc(l:outdir)
  endif
  let l:lines = s:run(l:args)
  if empty(l:lines) | return | endif
  echomsg 'image-inspect: exported to ' . join(l:lines, ' ')
endfunction
