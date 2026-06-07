if exists('b:current_syntax')
    finish
endif

" Code blocks take priority — define first so inline rules don't match inside
syntax region slackCodeBlock start=/^```/ end=/^```/ keepend
        \ contains=@NoSpell
syntax region slackCodeSpan  start=/`\(`\)\@!/ end=/`/ oneline
        \ contains=@NoSpell

" Bold: *text*
" [^* \t\n] ensures the char after * is not space/tab/NL/*, excluding list markers
syntax match slackBold /\*[^* \t\n][^*\n]*\*/
        \ contains=@NoSpell

" Italic: _text_
syntax match slackItalic /_[^_ \t\n][^_\n]*_/

" Strikethrough: ~text~
syntax match slackStrike /\~[^~ \t\n][^~\n]*\~/

" Blockquote: > line
syntax match slackBlockquote /^>.*$/
        \ contains=slackBold,slackItalic,slackStrike,slackCodeSpan

" Link: [text](URL)
syntax match slackLink /\[.\{-}\](\S\+)/
        \ contains=@NoSpell

" Heading: # text  (Slack renders # as literal but we highlight for editing)
syntax match slackHeading /^#\+\s.*/
        \ contains=slackBold,slackItalic

" List markers: - item  * item  1. item
syntax match slackListMarker /^\s*\zs[-*]\ze\s/
syntax match slackListMarker /^\s*\zs\d\+\.\ze\s/

" Emoji: :name:
syntax match slackEmoji /:[a-zA-Z0-9_+\-]\+:/

highlight default slackBold   cterm=bold                                    gui=bold
highlight default slackItalic cterm=italic                                  gui=italic
highlight default slackStrike cterm=strikethrough ctermfg=245               gui=strikethrough guifg=#808080
highlight default link slackCodeBlock   String
highlight default link slackCodeSpan    String
highlight default link slackBlockquote  Special
highlight default link slackLink        Underlined
highlight default link slackHeading     Title
highlight default link slackListMarker  Operator
highlight default link slackEmoji       Constant

let b:current_syntax = 'slack'
