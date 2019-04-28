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


function! FindAndReplaceAll(substituteCommand)
    normal! mZ
    let [word, replacement, flags] = ParseArgs(a:substituteCommand)
    call GrepForWord(word, 1)
    redraw!
    call ReplaceAllMatches(word, replacement, flags)
    call WriteLocationListItems()
    normal! `Z
endfunction


function ShouldReplaceMatches(replacement, flags)
    if a:replacement != ''
        return 1
    elseif a:flags != ''
        return 1
    else
        return 0
    endif
endfunction


function! ParseArgs(argString)
    let args = split(a:argString, '/')
    if len(args) < 3
        let args = args + ['']
    endif
    return args
endfunction


function! FindAll(word)
    normal! mZ
    call GrepForWord(a:word, -1)
    redraw!
    normal! `Z
    lopen
endfunction


function! GrepForWord(word, maxCount)
    let currentBufferFileExtension = expand('%:e')
    let filetypeGlobs = [GetFileTypeGlob(currentBufferFileExtension)]
    if g:supplantIgnoreCase
        let flags = GetCaseInsensitiveGrepFlags(maxCount)
    else
        let flags = GetCaseSensitiveGrepFlags(maxCount)
    endif
    let grepCommand = ConstructGrepCommand(WordToGrepPattern(a:word), flags)
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


function! ConstructGrepCommand(grepPattern, grepFlags)
    let searchDir = ' .'
    return 'silent lgrep'.a:grepFlags.a:grepPattern.searchDir
endfunction


function! GetCaseSensitiveGrepFlags(maxCount)
    let flags = ' -r'
    if a:maxCount > 0
        let flags = flags.' -m'.a:maxCount
    endif
    return flags.' -e'
endfunction


function! GetCaseInsensitiveGrepFlags(maxCount)
    let flags = ' -ri'
    if a:maxCount > 0
        let flags = flags.' -m'.a:maxCount
    endif
    return flags.' -e'
endfunction


function! AddGrepArgs(grepCommand, grepArgs)
    return a:grepCommand.a:grepArgs
endfunction


function! ConstructIncludeArgs(inclusions)
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


function! ReplaceAllMatches(word, replacement, flags)
    if len(getloclist(0)) == 0
        return
    endif
    let locListSubstituteCommand = GetLocListSubstituteCommand(a:word, a:replacement, a:flags)
    execute locListSubstituteCommand
endfunction


function! GetLocListSubstituteCommand(word, replacement, flags)
    let caseSensitiveFlag = g:supplantIgnoreCase ? '\c' : '\C'
    return 'lfdo %s/'.caseSensitiveFlag.'\<'.a:word.'\>/'.a:replacement.'/'.a:flags
endfunction


function! WriteLocationListItems()
    execute 'lfdo! update'
endfunction
