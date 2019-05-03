" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
"
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


" if exists('g:loadedSupplant')
"     finish
" endif


command! -nargs=1 Supplant :call s:Supplant(<q-args>)


function s:Supplant(argString) abort
    let l:supplanter = supplanter#Supplanter(a:argString)
    if l:supplanter.shouldMatchFileExtension
        if s:BufferHasFile()
            let l:fileExtensionGlobs = [s:GetBufferFileExtensionGlob()]
            call l:supplanter.AddIncludeGlobs(l:fileExtensionGlobs)
        endif
    endif
    let [l:ignoreFiles, l:ignoreDirs] = getgitignore#GetFilesAndDirs()
    call l:supplanter.AddExcludeDirGlobs(l:ignoreDirs)
    call l:supplanter.AddExcludeGlobs(l:ignoreFiles)
    call l:supplanter.FindAll()
endfunction


function! s:BufferHasFile() abort
    return &ft !=# 'netrw' && &ft != ''
endfunction


function! s:GetBufferFileExtensionGlob() abort
    return '*.' . expand('%:e')
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
