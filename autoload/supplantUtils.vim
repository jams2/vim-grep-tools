function! supplantUtils#GetLastChar(string) abort
    return strcharpart(a:string, len(a:string)-1, 1)
endfunction


function! supplantUtils#GetFirstChar(string) abort
    return strcharpart(a:string, 0, 1)
endfunction


function! supplantUtils#StripLastChar(string) abort
    return strcharpart(a:string, 0, len(a:string)-1)
endfunction


function! supplantUtils#StripFirstChar(string) abort
    return strcharpart(a:string, 1, len(a:string))
endfunction


function! supplantUtils#CharIsEscaped(string, index)
    if a:index == 0 | return 0 | endif
    if a:index > len(a:string) | throw 'Index out of bounds' | endif
    return a:string[a:index-1] == '\'
endfunction
