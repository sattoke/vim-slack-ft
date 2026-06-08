" Returns the string to execute when <CR> is pressed in insert mode.
"
" On a list line with content  → newline + same marker (ordered: incremented)
" On an empty list item        → <C-u> to clear the marker, stay on the line
" Elsewhere                    → plain <CR>
function! slack#ftplugin#cr() abort
    let line = getline('.')

    " Ordered list: leading spaces + number + ". "
    let m = matchlist(line, '^\(\s*\)\(\d\+\)\. ')
    if !empty(m)
        if line =~# '^\s*\d\+\.\s*$'
            return "\<C-u>"
        endif
        let nl = empty(m[1]) ? "\<CR>" : "\<CR>\<C-u>"
        return nl . m[1] . (m[2] + 1) . '. '
    endif

    " Unordered list: leading spaces + "- " or "* "
    let m = matchlist(line, '^\(\s*\)\([-*]\) ')
    if !empty(m)
        if line =~# '^\s*[-*]\s*$'
            return "\<C-u>"
        endif
        let nl = empty(m[1]) ? "\<CR>" : "\<CR>\<C-u>"
        return nl . m[1] . m[2] . ' '
    endif

    return "\<CR>"
endfunction
