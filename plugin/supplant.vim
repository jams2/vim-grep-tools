" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
" 
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


if !exists('g:supplantExcludeDirs') || type(g:supplantExcludeDirs) != v:t_list
    let g:supplantExcludeDirs = []
endif

if !exists('g:supplantIgnoreCase')
    let g:supplantIgnoreCase = 0
endif


command! -nargs=1 Supplant :call FindAndReplaceAll(<q-args>)
command! -nargs=1 SupplantFindAll :call FindAll(<f-args>)


function! FindAndReplaceAll(...)
    if a:0 != 1
        throw 'Expected one arg following :substitute syntax'
    endif
    normal! mZ
    let [l:word, l:substitute, l:flags] = s:ParseArgs(a:1)
    call GrepForWord(l:word)
    redraw!
    call ReplaceAllMatches(l:word, l:substitute, l:flags)
    call WriteLocationListItems()
    normal! `Z
endfunction


function! s:ParseArgs(argString)
    let args = split(a:argString, '/')
    if len(args) < 3
        let args = args + ['']
    endif
    return args
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
    if len(g:supplantExcludeDirs) == 0
        return ''
    endif
    let excludeDirArgs = ''
    for excludeDir in g:supplantExcludeDirs
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


function! ReplaceAllMatches(word, substitute, flags)
    if len(getloclist(0)) == 0
        return
    endif
    let locListSubstituteCommand = GetLocListSubstituteCommand(a:word, a:substitute, a:flags)
    execute locListSubstituteCommand
endfunction


function! GetLocListSubstituteCommand(word, substitute, flags)
    let caseSensitiveFlag = g:supplantIgnoreCase ? '\c' : '\C'
    return 'lfdo %s/'.caseSensitiveFlag.'\<'.a:word.'\>/'.a:substitute.'/'.a:flags
endfunction


function! WriteLocationListItems()
    execute 'lfdo! update'
endfunction
