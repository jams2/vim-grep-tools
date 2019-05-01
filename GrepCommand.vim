let g:GrepCommand = {}


function! g:GrepCommand.new(argString) abort
    let newInstance = copy(self)
    let newInstance.argString = a:argString
    return newInstance
endfunction
