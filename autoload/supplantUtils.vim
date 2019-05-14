function! supplantUtils#GetLastChar(string) abort
    return strcharpart(a:string, len(a:string)-1, 1)
endfunction


function! supplantUtils#GetFirstChar(string) abort
    return strcharpart(a:string, 0, 1)
endfunction


function! supplantUtils#StripLastChar(string) abort
    return strcharpart(a:string, 0, len(a:string)-1)
endfunction

