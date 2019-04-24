" greptools.vim - grep tools/helpers
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0


function! GrepForAnyInMatchingFiletype()
    let filetype = '*.' . expand('%:e')
    normal mZ
    let includes = ConstructGrepInclusions([filetype])
    let searchTerm = input('Enter search term >>> ')
    let grepCommand = 'silent lgrep -r -e "\b' . searchTerm . '\b" . ' . g:excludeDirs . includes
    execute grepCommand
    redraw!
    echo 'Found ' . len(getloclist(0)) . ' occurences of "' . searchTerm . '".'
    normal `Z
endfunction


function! GrepForSearchTerm(searchTerm)
    """ grep for all occurences in files of same type as buffer.
    normal mZ
    let filetype = '*.' . expand('%:e')
    let includes = ConstructGrepInclusions([filetype])
    let grepCommand = 'silent lgrep -r -e "\b' . a:searchTerm . '\b" . ' . g:excludeDirs . includes
    execute grepCommand
    redraw!
    normal `Z
    let found = len(getloclist(0))
    echo '[+] Found ' . found . ' occurences of "' . a:searchTerm . '"'
endfunction


function! GrepAndReplaceAll(searchTerm, ...)
    """ Optional args are 'include=' arguments to grep.
    normal mZ
    let includes = ConstructGrepInclusions(a:000)
    let grepCommand = ConstructGrepCommand(a:searchTerm, includes)
    execute grepCommand
    redraw!
    call ReplaceAllMatches(a:searchTerm)
    call WriteQuickfixItems()
    normal `Z
endfunction

function! ConstructGrepInclusions(inclusions)
    """ inclusions must be a list.
    let includes = ''
    for inclusion in a:inclusions
        let includes = includes . '--include="' . inclusion . '" '
    endfor
    return includes
endfunction

function! ConstructGrepCommand(searchTerm, includes)
    let grepFlags = '-r -m 1 -e'
    let grepCommand = 'silent lgrep ' . grepFlags .  ' "\b' . a:searchTerm
    let grepCommand = grepCommand . '\b" . ' . g:excludeDirs
    if a:includes == ''
        return grepCommand
    else
        let grepCommand = grepCommand . a:includes
    endif
    return grepCommand
endfunction

function! ReplaceAllMatches(searchTerm)
    let filesWithMatchesCount = len(getloclist(0))
    if filesWithMatchesCount == 0
        return
    endif
    echo '[*] Found' filesWithMatchesCount 'files with matches.'
    let replacementPrompt = '[+] Enter replacement for "' . a:searchTerm . '" >>> '
    let replacement = input(replacementPrompt)
    execute 'cfdo %s/\<' . a:searchTerm . '\>/' . replacement . '/gc'
endfunction

function! WriteQuickfixItems()
    execute 'cfdo update'
endfunction
