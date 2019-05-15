function! getgitignore#GetFilesAndDirs() abort
    let l:gitIgnore = ReadGitIgnore(s:GetGitIgnorePath())
    let [l:fileNames, l:dirNames] = s:GetFilesAndDirs(l:gitIgnore)
    return [l:fileNames, l:dirNames]
endfunction


function! s:GetGitIgnorePath() abort
    return findfile('.gitignore', '.;')
endfunction


function! ReadGitIgnore(gitignore) abort
    return filereadable(a:gitignore) ? readfile(a:gitignore) : []
endfunction


function! s:GetFilesAndDirs(gitIgnores) abort
    let [l:fileNames, l:dirNames] = [[], []]
    for line in a:gitIgnores
        if s:IsCommentOrBlankLine(line)
            continue
        elseif supplantUtils#GetLastChar(line) == '/'
            call add(l:dirNames, supplantUtils#StripLastChar(line))
        else
            call add(l:fileNames, line)
        endif
    endfor
    return [l:fileNames, l:dirNames]
endfunction


function! s:IsCommentOrBlankLine(line)
    return supplantUtils#GetFirstChar(a:line) == '#' ||
                \ supplantUtils#GetFirstChar(a:line) == ''
endfunction
