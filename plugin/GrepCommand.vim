let s:MAX_COMMAND_ARGS = 3


function! GrepCommand(argString) abort
    let grepCommand = {
                \ 'argString': a:argString,
                \ 'restrictFiletype': 1,
                \ 'word': '',
                \ 'replacement': '',
                \ 'flags': '',
                \ 'ParseArgs': function('ParseArgs'),
                \ 'HasExtraFlags': {argString -> len(split(argString, ' -')) > 1},
                \ 'HandleExtraFlags': function('HandleExtraFlags'),
                \ }

    let [grepCommand.word, grepCommand.replacement, grepCommand.flags] = 
                \ grepCommand.ParseArgs()


    return grepCommand
endfunction


function! ParseArgs() abort dict
    if self.HasExtraFlags(self.argString)
        call self.HandleExtraFlags()
    endif
    let args = split(self.argString, '/')
    if len(args) > s:MAX_COMMAND_ARGS
        throw 'Invalid :substitute string'
    endif
    while s:MAX_COMMAND_ARGS - len(args) > 0
        let args += ['']
    endwhile
    return args
endfunction

function! HandleExtraFlags() abort dict
    let splitArgs = split(self.argString, ' -')
    let extraFlags = remove(splitArgs, 1, -1)
    if index(extraFlags, 'f') >= 0
        let self.restrictFiletype = 0
    endif
endfunction
