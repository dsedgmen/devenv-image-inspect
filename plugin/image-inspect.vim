" plugin/image-inspect.vim — commands for devenv-image-inspect
if exists('g:loaded_image_inspect')
  finish
endif
let g:loaded_image_inspect = 1

command! -nargs=? ImageInspect call image_inspect#inspect(<f-args>)
command! -nargs=? ImageMeta call image_inspect#meta(<f-args>)
command! -nargs=? ImageHistory call image_inspect#history(<f-args>)
command! -nargs=* ImageFs call image_inspect#fs(<f-args>)
command! -nargs=* ImageExport call image_inspect#export(<f-args>)

if get(g:, 'image_inspect_map_keys', 1)
  nnoremap <silent> <Leader>ii :ImageInspect<CR>
  nnoremap <silent> <Leader>im :ImageMeta<CR>
  nnoremap <silent> <Leader>ih :ImageHistory<CR>
  nnoremap <silent> <Leader>if :ImageFs<CR>
  nnoremap <silent> <Leader>ie :ImageExport<CR>
endif
