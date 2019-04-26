" greptools.vim - grep tools/helpers
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
" 
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


if !exists('g:grepToolsExcludeDirs') || type(g:grepToolsExcludeDirs) != v:t_list
    let g:grepToolsExcludeDirs = []
endif


command! -nargs=+ GTReplaceAll :call FindAndReplaceAll(<f-args>)
command! -nargs=1 GTFindAll :call FindAll(<f-args>)


function! FindAndReplaceAll(word, replacement)
    normal! mZ
    call GrepForWord(a:word)
    redraw!
    call ReplaceAllMatches(a:word, a:replacement)
    call WriteLocationListItems()
    normal! `Z
endfunction


function! FindAll(word)
    normal! mZ
    call GrepForWord(a:word)
    redraw!
    normal! `Z
    lopen
endfunction


function! GrepForWord(word)
    let currentBufferFileExtension = expand('%:e')
    let filetypeGlobs = [GetFileTypeGlob(currentBufferFileExtension)]
    let FlagGetter = function('GetCaseSensitiveGrepFlags')
    let grepCommand = ConstructGrepCommand(WordToGrepPattern(a:word), FlagGetter)
    let grepCommand = AddGrepArgs(grepCommand, ConstructIncludeArgs(filetypeGlobs))
    let grepCommand = AddGrepArgs(grepCommand, ConstructExcludeDirArgs())
    execute grepCommand
endfunction


function! WordToGrepPattern(word)
    return ' "\b'.a:word.'\b"'
endfunction


function! GetFileTypeGlob(fileExtension)
    return '*.'.a:fileExtension
endfunction


function! ConstructGrepCommand(grepPattern, FlagGetter)
    let grepFlags = a:FlagGetter()
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
    if len(g:grepToolsExcludeDirs) == 0
        return ''
    endif
    let excludeDirArgs = ''
    for excludeDir in g:grepToolsExcludeDirs
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


function! ReplaceAllMatches(word, replacement)
    let filesWithMatchesCount = len(getloclist(0))
    if filesWithMatchesCount == 0
        return
    endif
    echo '[*] Found' filesWithMatchesCount 'files with matches.'
    execute 'lfdo %s/\C\<' . a:word . '\>/' . a:replacement . '/gc'
endfunction


function! WriteLocationListItems()
    execute 'lfdo! update'
endfunction
