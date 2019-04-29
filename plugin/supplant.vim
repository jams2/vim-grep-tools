" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
" 
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


if exists('g:loadedSupplant')
    finish
endif
let g:loadedSupplant = 1
if !exists('g:supplantExcludeDirs') || type(g:supplantExcludeDirs) != v:t_list
    let g:supplantExcludeDirs = []
endif
if !exists('g:supplantIgnoreCase')
    let g:supplantIgnoreCase = 0
endif
let s:INCLUDE_MAX_COUNT = 1
let s:MAX_ARGS = 3


command! -nargs=1 Supplant :call FindOrReplaceAll(<q-args>)


function! FindOrReplaceAll(substituteCommand) abort
    let [word, replacement, flags] = ParseArgs(a:substituteCommand)
    if ShouldReplaceMatches(replacement, flags)
        call FindAndReplaceAll(word, replacement, flags)
    else
        call FindAll(word)
    endif
endfunction


function! ParseArgs(argString) abort
    let args = split(a:argString, '/')
    if len(args) > s:MAX_ARGS
        throw 'Invalid :substitute string'
    endif
    while s:MAX_ARGS - len(args) > 0
        let args += ['']
    endwhile
    return args
endfunction


function! ShouldReplaceMatches(replacement, flags) abort
    if a:replacement != ''
        return 1
    elseif a:flags != ''
        return 1
    else
        return 0
    endif
endfunction


function! FindAndReplaceAll(word, replacement, flags) abort
    normal! mZ
    call GrepForWord(a:word, s:INCLUDE_MAX_COUNT)
    redraw!
    call ReplaceAllMatches(a:word, a:replacement, a:flags)
    call WriteLocationListItems()
    normal! `Z
endfunction


function! FindAll(word) abort
    normal! mZ
    call GrepForWord(a:word, !s:INCLUDE_MAX_COUNT)
    redraw!
    normal! `Z
    call AddFindAllLocationListMessage(a:word)
    lopen
endfunction


function! GrepForWord(word, maxCount) abort
    let currentBufferFileExtension = expand('%:e')
    let filetypeGlobs = [GetFileTypeGlob(currentBufferFileExtension)]
    if g:supplantIgnoreCase
        let flags = GetCaseInsensitiveGrepFlags(a:maxCount)
    else
        let flags = GetCaseSensitiveGrepFlags(a:maxCount)
    endif
    let grepCommand = ConstructGrepCommand(WordToGrepPattern(a:word), flags)
    let grepCommand = AddGrepArgs(grepCommand, ConstructIncludeArgs(filetypeGlobs))
    let grepCommand = AddGrepArgs(grepCommand, ConstructExcludeDirArgs())
    execute grepCommand
endfunction


function! GetFileTypeGlob(fileExtension) abort
    return '*.'.a:fileExtension
endfunction


function! GetCaseInsensitiveGrepFlags(maxCount) abort
    let flags = ' -ri'
    if a:maxCount > 0
        let flags = flags.' -m'.a:maxCount
    endif
    return flags.' -e'
endfunction


function! GetCaseSensitiveGrepFlags(maxCount) abort
    let flags = ' -r'
    if a:maxCount > 0
        let flags = flags.' -m'.a:maxCount
    endif
    return flags.' -e'
endfunction


function! ConstructGrepCommand(grepPattern, grepFlags) abort
    let searchDir = ' .'
    return 'silent lgrep'.a:grepFlags.a:grepPattern.searchDir
endfunction


function! WordToGrepPattern(word) abort
    return ' "\b'.a:word.'\b"'
endfunction


function! AddGrepArgs(grepCommand, grepArgs) abort
    return a:grepCommand.a:grepArgs
endfunction


function! ConstructIncludeArgs(inclusions) abort
    """ inclusions must be a list.
    if type(a:inclusions) != v:t_list
        throw 'ConstructIncludeArgs expected type <v:t_list>'
    endif
    if len(a:inclusions) == 0
        return ''
    endif
    let includeArgs = ''
    for inclusion in a:inclusions
        let includeArgs = includeArgs . ' --include="'.inclusion.'"'
    endfor
    return includeArgs
endfunction


function! ConstructExcludeDirArgs(...) abort
    let excludeDirArgs = ConstructExcludeDirArgsFromGlobalSetting()
    if len(a:000) > 0
        let excludeDirArgs = AddExtraExcludeDirArgs(excludeDirArgs, a:000)
    endif
    return excludeDirArgs
endfunction


function! ConstructExcludeDirArgsFromGlobalSetting() abort
    if len(g:supplantExcludeDirs) == 0
        return ''
    endif
    let excludeDirArgs = ''
    for excludeDir in g:supplantExcludeDirs
        let excludeDirArgs = ConcatExcludeDirArgs(excludeDirArgs, excludeDir)
    endfor
    return excludeDirArgs
endfunction


function! AddExtraExcludeDirArgs(existingArgs, extraDirs) abort
    if type(a:extraDirs) != v:t_list
        throw "expected type <list> for arg extraDirs"
    elseif len(a:extraDirs) == 0
        return a:existingArgs
    endif
    let excludeDirArgs = a:existingArgs
    for extraDir in a:extraDirs
        let excludeDirArgs = ConcatExcludeDirArgs(excludeDirArgs, extraDir)
    endfor
    return excludeDirArgs
endfunction


function! ConcatExcludeDirArgs(existingArgs, nextDir) abort
    return a:existingArgs.' --exclude-dir="'.a:nextDir.'"'
endfunction


function! AddFindAllLocationListMessage(word) abort
    let matchCount = len(getloclist(0))
    let title = 'Supplant found '.matchCount.' occurences of "'.a:word.'"'
    call setloclist(0, [], 'r', {'title': title})
endfunction


function! ReplaceAllMatches(word, replacement, flags) abort
    if len(getloclist(0)) == 0
        return
    endif
    let locListSubstituteCommand = GetLocListSubstituteCommand(a:word, a:replacement, a:flags)
    execute locListSubstituteCommand
endfunction


function! GetLocListSubstituteCommand(word, replacement, flags) abort
    let caseSensitiveFlag = g:supplantIgnoreCase ? '\c' : '\C'
    return 'lfdo %s/'.caseSensitiveFlag.'\<'.a:word.'\>/'.a:replacement.'/'.a:flags
endfunction


function! WriteLocationListItems() abort
    execute 'lfdo! update'
endfunction
