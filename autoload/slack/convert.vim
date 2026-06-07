" Placeholder character (SOH, ASCII 1) used internally during conversion
" to protect already-converted spans from a second pass.
let s:PH = "\x01"

" Public: convert lines line1..line2 in the current buffer.
" direction is 'to_gfm' or 'to_slack'.
function! slack#convert#range(line1, line2, direction) abort
    let Fn = a:direction ==# 'to_gfm'
            \ ? function('s:to_gfm')
            \ : function('s:to_slack')
    let lines = getline(a:line1, a:line2)
    let in_code_block = 0
    for i in range(len(lines))
        if lines[i] =~# '^```'
            let in_code_block = !in_code_block
        elseif !in_code_block
            let lines[i] = Fn(lines[i])
        endif
    endfor
    call setline(a:line1, lines)
endfunction

" ── GFM → Slack ──────────────────────────────────────────────────────────────

function! s:to_slack(line) abort
    let l = a:line

    " Heading: # Title  →  # *Title*
    if l =~# '^#\+\s\+'
        return substitute(l, '^\(#\+\s\+\)\(.*\)', '\1*\2*', '')
    endif

    " Preserve the list marker (- / * / 1.) and process the rest separately
    let [pfx, rest] = s:split_list(l)

    " 1. Protect bold **...** with placeholder so the italic pass ignores it
    let rest = substitute(rest, '\*\*\([^*\n]\+\)\*\*',
            \ s:PH . '\1' . s:PH, 'g')

    " 2. Convert italic *...* → _..._
    "    [^* \t\n] prevents matching list markers or empty spans
    let rest = substitute(rest, '\*\([^* \t\n][^*\n]*\)\*', '_\1_', 'g')

    " 3. Restore placeholder → *...*  (bold in Slack)
    let rest = substitute(rest,
            \ s:PH . '\([^' . s:PH . ']*\)' . s:PH, '*\1*', 'g')

    " 4. Strikethrough ~~...~~ → ~...~
    let rest = substitute(rest, '\~\~\([^~\n]\+\)\~\~', '~\1~', 'g')

    return pfx . rest
endfunction

" ── Slack → GFM ──────────────────────────────────────────────────────────────

function! s:to_gfm(line) abort
    let l = a:line

    " Heading: # *Title*  →  # Title
    if l =~# '^#\+\s\+\*.\+\*$'
        return substitute(l, '^\(#\+\s\+\)\*\(.*\)\*$', '\1\2', '')
    endif

    let [pfx, rest] = s:split_list(l)

    " Bold *...* → **...**
    let rest = substitute(rest, '\*\([^* \t\n][^*\n]*\)\*', '**\1**', 'g')

    " Italic _..._ → _..._ (GFM も _..._ を斜体として扱うので変換不要)

    " Strikethrough ~...~ → ~~...~~
    let rest = substitute(rest, '\~\([^~ \t\n][^~\n]*\)\~', '~~\1~~', 'g')

    return pfx . rest
endfunction

" ── Helpers ───────────────────────────────────────────────────────────────────

" Split a line into [list_marker_prefix, rest].
" Recognises:  - item  * item  + item  1. item  (with optional leading spaces)
function! s:split_list(line) abort
    let marker = matchstr(a:line, '^\s*\%(\%([-*+]\|\d\+\.\)\s\+\)')
    return [marker, a:line[len(marker):]]
endfunction
