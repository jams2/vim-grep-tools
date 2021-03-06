function supplant#Supplant(argString) abort
    normal! mZ
    let l:supplanter = supplanter#Supplanter(a:argString)
    if l:supplanter.shouldMatchFileExtension && s:BufferContainsFile()
        let l:fileExtensionGlobs = [s:GetBufferFileExtensionGlob()]
        call l:supplanter.AddIncludeGlobs(l:fileExtensionGlobs)
    endif
    for dirList in [g:gitIgnoreDirs, g:supplantIgnoreDirs]
        call l:supplanter.AddExcludeDirGlobs(dirList)
    endfor
    for fileList in [g:gitIgnoreFiles, g:supplantIgnoreFiles]
        call l:supplanter.AddExcludeGlobs(fileList)
    endfor
    call l:supplanter.FindAll()
    if l:supplanter.shouldReplaceMatches
        call l:supplanter.ReplaceAll()
        call s:WriteLocationListItems()
        normal! `Z
    else
        call s:AddFindAllLocationListMessage(l:supplanter.word)
        lopen
    endif
endfunction


function! s:BufferContainsFile() abort
    return &ft !=# 'netrw' && &ft != ''
endfunction


function! s:GetBufferFileExtensionGlob() abort
    return '*.' . expand('%:e')
endfunction


function! s:AddFindAllLocationListMessage(word) abort
    let matchCount = len(getloclist(0))
    let title = 'Supplant found '.matchCount.' occurences of "'.a:word.'"'
    call setloclist(0, [], 'r', {'title': title})
endfunction


function! s:WriteLocationListItems() abort
    execute 'lfdo! update'
endfunction

