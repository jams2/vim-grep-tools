function supplant#Supplant(argString) abort
    normal! mZ
    let l:supplanter = supplanter#Supplanter(a:argString)
    if l:supplanter.shouldMatchFileExtension && s:BufferContainsFile()
        let l:fileExtensionGlobs = [s:GetBufferFileExtensionGlob()]
        call l:supplanter.AddIncludeGlobs(l:fileExtensionGlobs)
    endif
    let [l:ignoreFiles, l:ignoreDirs] = getgitignore#GetFilesAndDirs()
    call l:supplanter.AddExcludeDirGlobs(l:ignoreDirs)
    call l:supplanter.AddExcludeGlobs(l:ignoreFiles)
    call l:supplanter.FindAll()
    if l:supplanter.shouldReplaceMatches
        call l:supplanter.ReplaceAll()
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


function! WriteLocationListItems() abort
    execute 'lfdo! update'
endfunction

