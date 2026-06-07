" Select inside (around=0) or around (around=1) a delimiter pair on the
" current line.  Works from both onoremap and xnoremap contexts.
function! slack#textobj#select(char, around) abort
    let line = getline('.')
    let pos  = col('.') - 1   " 0-indexed cursor position

    " Search backwards from cursor for an opening delimiter
    let open = s:find_backward(line, a:char, pos)

    " If none behind, look forward
    if open < 0
        let open = s:find_forward(line, a:char, pos)
    endif
    if open < 0
        return
    endif

    " Closing delimiter must follow the opening one
    let close = s:find_forward(line, a:char, open + 1)
    if close < 0
        return
    endif

    " Cursor must be within the delimited span
    if pos < open || pos > close
        return
    endif

    let lnum = line('.')
    if a:around
        call cursor(lnum, open + 1)   " 1-indexed
        normal! v
        call cursor(lnum, close + 1)
    else
        call cursor(lnum, open + 2)
        normal! v
        call cursor(lnum, close)
    endif
endfunction

" Wrap the current visual selection with char on both sides.
" Handles single-line and multi-line selections.
function! slack#textobj#wrap(char) abort
    let [sl, sc] = [line("'<"), col("'<")]
    let [el, ec] = [line("'>"), col("'>")]

    if sl == el
        let ln = getline(sl)
        call setline(sl,
                \ strpart(ln, 0, sc - 1) . a:char
                \ . strpart(ln, sc - 1, ec - sc + 1) . a:char
                \ . strpart(ln, ec))
    else
        " Modify end line first so start-line col positions stay valid
        let ln = getline(el)
        call setline(el, strpart(ln, 0, ec) . a:char . strpart(ln, ec))
        let ln = getline(sl)
        call setline(sl, strpart(ln, 0, sc - 1) . a:char . strpart(ln, sc - 1))
    endif
endfunction

" ── private helpers ──────────────────────────────────────────────────────────

function! s:find_backward(line, char, from) abort
    let i = a:from
    while i >= 0
        if a:line[i] ==# a:char
            return i
        endif
        let i -= 1
    endwhile
    return -1
endfunction

function! s:find_forward(line, char, from) abort
    let i = a:from
    while i < len(a:line)
        if a:line[i] ==# a:char
            return i
        endif
        let i += 1
    endwhile
    return -1
endfunction
