" greptools.vim - grep tools/helpers
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
" 
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


if !exists('g:excludeDirs') || type(g:excludeDirs) != v:t_list
    let g:excludeDirs = []
endif


function! GrepAndReplaceAll(word)
    normal! mZ
    call GrepForWord(a:word)
    call ReplaceAllMatches(a:word)
    call WriteLocationListItems()
    normal! `Z
endfunction


function! GrepForWord(word)
    let currentBufferFileExtension = expand('%:e')
    let filetypeGlobs = [GetFileTypeGlob(currentBufferFileExtension)]
    let flagGetter = function('GetCaseSensitiveGrepFlags')
    let grepCommand = ConstructGrepCommand(WordToGrepPattern(a:word), flagGetter)
    let grepCommand = AddGrepArgs(grepCommand, ConstructIncludeArgs(filetypeGlobs))
    let grepCommand = AddGrepArgs(grepCommand, ConstructExcludeDirArgs())
    execute grepCommand
    redraw!
endfunction


function! WordToGrepPattern(word)
    return ' "\b'.a:word.'\b"'
endfunction


function! GetFileTypeGlob(fileExtension)
    return '*.'.a:fileExtension
endfunction


function! ConstructGrepCommand(grepPattern, flagGetter)
    let grepFlags = a:flagGetter()
    let searchDir = ' .'
    return 'silent lgrep'.grepFlags.a:grepPattern.searchDir
endfunction


function! GetCaseSensitiveGrepFlags()
    return ' -r -m 1 -e'
endfunction


function! GetCaseInsensitiveGrepFlags()
    return ' -ri -m 1 -e'
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


function! ReplaceAllMatches(word)
    let filesWithMatchesCount = len(getloclist(0))
    if filesWithMatchesCount == 0
        return
    endif
    echo '[*] Found' filesWithMatchesCount 'files with matches.'
    let replacementPrompt = '[+] Enter replacement for "' . a:word . '" >>> '
    let replacement = input(replacementPrompt)
    execute 'lfdo %s/\C\<' . a:word . '\>/' . replacement . '/gc'
endfunction


function! WriteLocationListItems()
    execute 'lfdo! update'
endfunction
