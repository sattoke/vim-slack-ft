if exists('b:did_ftplugin')
    finish
endif
let b:did_ftplugin = 1

setlocal wrap
setlocal linebreak
setlocal textwidth=0
setlocal formatoptions-=t

let b:undo_ftplugin = 'setlocal wrap< linebreak< textwidth< formatoptions<'
        \ . '| execute "iunmap <buffer> <CR>"'

" List continuation: <CR> on a list line inserts the same marker on the next line
inoremap <buffer><expr> <CR> slack#ftplugin#cr()

" Conversion commands (operate on range or whole buffer)
command! -buffer -range=% SlackToGFM
        \ call slack#convert#range(<line1>, <line2>, 'to_gfm')
command! -buffer -range=% GFMToSlack
        \ call slack#convert#range(<line1>, <line2>, 'to_slack')

" Visual-mode: wrap selection in markup delimiters
xnoremap <buffer><silent> <leader>b :<C-u>call slack#textobj#wrap('*')<CR>
xnoremap <buffer><silent> <leader>i :<C-u>call slack#textobj#wrap('_')<CR>
xnoremap <buffer><silent> <leader>s :<C-u>call slack#textobj#wrap('~')<CR>

" Text objects: i* a*  i_ a_  i~ a~
for s:c in ['*', '_', '~']
    execute 'onoremap <buffer><silent> i' . s:c
            \ . ' :<C-u>call slack#textobj#select(' . string(s:c) . ', 0)<CR>'
    execute 'xnoremap <buffer><silent> i' . s:c
            \ . ' :<C-u>call slack#textobj#select(' . string(s:c) . ', 0)<CR>'
    execute 'onoremap <buffer><silent> a' . s:c
            \ . ' :<C-u>call slack#textobj#select(' . string(s:c) . ', 1)<CR>'
    execute 'xnoremap <buffer><silent> a' . s:c
            \ . ' :<C-u>call slack#textobj#select(' . string(s:c) . ', 1)<CR>'
endfor
unlet s:c
