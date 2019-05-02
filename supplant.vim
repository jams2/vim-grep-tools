" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
" 
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.
"
"
" TODO:
" - add a substitute flag parser, add handling for an [f|F] flag:
"   [f] search in all filetypes, [F] search only in files matching current
"   buffer
" - handle grep compatibility
"


" if exists('g:loadedSupplant')
"     finish
" endif
let g:loadedSupplant = 1
if !exists('g:supplantExcludeDirs') || type(g:supplantExcludeDirs) != v:t_list
    let g:supplantExcludeDirs = []
endif
if !exists('g:supplantIgnoreCase')
    let g:supplantIgnoreCase = 0
endif
let s:INCLUDE_MAX_COUNT = 1
let s:MAX_COMMAND_ARGS = 3
let s:INCLUDE_BUFFER_FILETYPE = 1


command! -nargs=1 Supplant :call FindOrReplaceAll(<q-args>)

if !exists('s:gitignoreFiles') && !exists('s:gitignoreDirs')
    let [s:gitignoreFiles, s:gitignoreDirs] = GetFilesAndDirs(ReadGitIgnore(FindGitIgnore()))
endif


function! FindOrReplaceAll(substituteCommand) abort
    let [word, replacement, flags] = ParseArgs(a:substituteCommand)
    if ShouldReplaceMatches(replacement, flags)
        let s:INCLUDE_BUFFER_FILETYPE = 1
        call FindAndReplaceAll(word, replacement, flags)
    else
        let s:INCLUDE_BUFFER_FILETYPE = 0
        call FindAll(word)
    endif
endfunction


function! ParseArgs(argString) abort
    if HasExtraFlags(a:argString)
        " do something with it.
    endif
    let args = split(a:argString, '/')
    if len(args) > s:MAX_COMMAND_ARGS
        throw 'Invalid :substitute string'
    endif
    while s:MAX_COMMAND_ARGS - len(args) > 0
        let args += ['']
    endwhile
    return args
endfunction


function! HasExtraFlags(argString)
    return len(split(a:argString, ' -')) > 1
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
    call ReplaceAllMatches(a:word, a:replacement, a:flags)
    call WriteLocationListItems()
    normal! `Z
endfunction


function! FindAll(word) abort
    call GrepForWord(a:word, !s:INCLUDE_MAX_COUNT)
    call AddFindAllLocationListMessage(a:word)
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
    let grepCommand = AddGrepArgs(grepCommand, ConstructNamedParameters(filetypeGlobs, 'include'))
    let grepCommand = AddGrepArgs(grepCommand, ConstructNamedParameters(s:gitignoreFiles, 'exclude'))
    let grepCommand = AddGrepArgs(grepCommand, ConstructExcludeDirArgs(s:gitignoreDirs))
    execute "silent lgetexpr system('".grepCommand."')"
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
    return &grepprg.a:grepFlags.a:grepPattern.searchDir
endfunction


function! WordToGrepPattern(word) abort
    return ' "\b'.a:word.'\b"'
endfunction


function! AddGrepArgs(grepCommand, grepArgs) abort
    return a:grepCommand.a:grepArgs
endfunction


function! ConstructNamedParameters(values, parameter) abort
    if type(a:values) != v:t_list
        throw 'ConstructNamedParameters expected type <v:t_list>'
    endif
    if len(a:values) == 0
        return ''
    endif
    let args = ''
    for value in a:values
        let args = args . ' --'.a:parameter.'="'.value.'"'
    endfor
    return args
endfunction


function! ConstructExcludeDirArgs(...) abort
    let excludeDirArgs = ConstructExcludeDirArgsFromGlobalSetting()
    if len(a:000) > 0
        let excludeDirArgs = AddExtraExcludeDirArgs(excludeDirArgs, a:1)
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