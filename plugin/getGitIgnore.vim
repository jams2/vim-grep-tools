function! FindGitIgnore() abort
    return findfile('.gitignore', '.;')
endfunction


function! ReadGitIgnore(gitignore) abort
    if !filereadable(a:gitignore)
        return []
    endif
    return readfile(a:gitignore)
endfunction


function! GetFilesAndDirs(gitIgnores) abort
    let [fileNames, dirNames] = [[], []]
    for pattern in a:gitIgnores
        if GetLastChar(pattern) == '/'
            call add(dirNames, pattern)
        else
            call add(fileNames, pattern)
        endif
    endfor
    return [fileNames, dirNames]
endfunction


function! GetLastChar(string) abort
    return strcharpart(a:string, len(a:string)-1, 1)
endfunction

