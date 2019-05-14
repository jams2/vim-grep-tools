function getgitignore#GetFilesAndDirs() abort
    let l:gitIgnore = ReadGitIgnore(s:GetGitIgnorePath())
    let [l:fileNames, l:dirNames] = s:GetFilesAndDirs(l:gitIgnore)
    return [l:fileNames, l:dirNames]
endfunction


function! s:GetGitIgnorePath() abort
    return findfile('.gitignore', '.;')
endfunction


function! ReadGitIgnore(gitignore) abort
    if !filereadable(a:gitignore)
        return []
    endif
    return readfile(a:gitignore)
endfunction


function! s:GetFilesAndDirs(gitIgnores) abort
    let [l:fileNames, l:dirNames] = [[], []]
    for line in a:gitIgnores
        if s:GetLastChar(line) == '/'
            call add(l:dirNames, s:StripLastChar(line))
        else
            call add(l:fileNames, line)
        endif
    endfor
    return [l:fileNames, l:dirNames]
endfunction


function! s:GetLastChar(string) abort
    return strcharpart(a:string, len(a:string)-1, 1)
endfunction


function! s:GetFirstChar(string) abort
    return strcharpart(a:string, 0, 1)
endfunction
function! s:StripLastChar(string) abort
    return strcharpart(a:string, 0, len(a:string)-1)
endfunction
