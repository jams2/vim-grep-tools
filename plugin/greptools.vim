" greptools.vim - grep tools/helpers
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0


if !exists('g:excludeDirs') || type(g:excludeDirs) != v:t_list
    let g:excludeDirs = []
endif


function! GrepAndReplaceAll(searchTerm)
    normal! mZ
    let grepPattern = SearchTermToGrepPattern(a:searchTerm)
    let currentBufferFileExtension = expand('%:e')
    let filetypeGlobs = [GetFileTypeGlob(currentBufferFileExtension)]
    let grepCommand = ConstructGrepCommand(grepPattern)
    let grepCommand = AddGrepArgs(grepCommand, ConstructIncludeArgs(filetypeGlobs))
    let grepCommand = AddGrepArgs(grepCommand, ConstructExcludeDirArgs())
    execute grepCommand
    redraw!
    call ReplaceAllMatches(a:searchTerm)
    call WriteQuickfixItems()
    normal! `Z
endfunction


function! SearchTermToGrepPattern(searchTerm)
    return ' "\b'.a:searchTerm.'\b"'
endfunction


function! GetFileTypeGlob(fileExtension)
    return '*.'.a:fileExtension
endfunction


function! ConstructGrepCommand(grepPattern)
    let grepFlags = ' -r -m 1 -e'
    let searchDir = ' .'
    return 'silent lgrep'.grepFlags.a:grepPattern.searchDir
endfunction


function! AddGrepArgs(grepCommand, grepArgs)
    return a:grepCommand.a:grepArgs
endfunction


function! GrepForAnyInMatchingFiletype()
    let filetype = '*.' . expand('%:e')
    normal! mZ
    let includes = ConstructIncludeArgs([filetype])
    let searchTerm = input('Enter search term >>> ')
    let grepCommand = 'silent lgrep -r -e "\b' . searchTerm . '\b" . ' . g:excludeDirs . includes
    execute grepCommand
    redraw!
    echo 'Found ' . len(getloclist(0)) . ' occurences of "' . searchTerm . '".'
    normal! `Z
endfunction


function! GrepForSearchTerm(searchTerm)
    """ grep for all occurences in files of same type as buffer.
    normal! mZ
    let filetype = '*.' . expand('%:e')
    let includeArgs = ConstructIncludeArgs([filetype])
    let grepCommand = 'silent lgrep -r -e "\b' . a:searchTerm . '\b" . ' . g:excludeDirs . includeArgs
    execute grepCommand
    redraw!
    normal! `Z
    let found = len(getloclist(0))
    echo '[+] Found ' . found . ' occurences of "' . a:searchTerm . '"'
endfunction


function! ConstructIncludeArgs(inclusions)
    """ inclusions must be a list.
    if len(a:inclusions) == 0
        return ''
    endif
    let includeArgs = ''
    for inclusion in a:inclusions
        let includeArgs = includeArgs . ' --include="'.inclusion.'"'
    endfor
    return includeArgs
endfunction


function! ConstructExcludeDirArgs(...)
    let excludeDirArgs = ConstructExcludeDirArgsFromGlobalSetting()
    if len(a:000) > 0
        let excludeDirArgs = AddExtraExcludeDirArgs(excludeDirArgs, a:000)
    endif
    return excludeDirArgs
endfunction


function ConstructExcludeDirArgsFromGlobalSetting()
    if len(g:excludeDirs) == 0
        return ''
    endif
    let excludeDirArgs = ''
    for excludeDir in g:excludeDirs
        let excludeDirArgs = ConcatExcludeDirArgs(excludeDirArgs, excludeDir)
    endfor
    return excludeDirArgs
endfunction


function AddExtraExcludeDirArgs(existingArgs, extraDirs)
    if type(a:extraDirs) != v:t_list
        throw "expected type <list> for arg extraDirs"
    elseif len(a:extraDirs) == 0
        return existingArgs
    endif
    let excludeDirArgs = a:existingArgs
    for extraDir in a:extraDirs
        let excludeDirArgs = ConcatExcludeDirArgs(excludeDirArgs, extraDir)
    endfor
    return excludeDirArgs
endfunction


function ConcatExcludeDirArgs(existingArgs, nextDir)
    return a:existingArgs.' --exclude-dir="'.a:nextDir.'"'
endfunction


function! ReplaceAllMatches(searchTerm)
    let filesWithMatchesCount = len(getloclist(0))
    if filesWithMatchesCount == 0
        return
    endif
    echo '[*] Found' filesWithMatchesCount 'files with matches.'
    let replacementPrompt = '[+] Enter replacement for "' . a:searchTerm . '" >>> '
    let replacement = input(replacementPrompt)
    execute 'cfdo %s/\C\<' . a:searchTerm . '\>/' . replacement . '/gc'
endfunction


function! WriteQuickfixItems()
    execute 'cfdo update'
endfunction
