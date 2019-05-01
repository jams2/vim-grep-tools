let s:MAX_COMMAND_ARGS = 3


function! GrepCommand(argString) abort
    let grepCommand = {
                \ 'argString': a:argString,
                \ 'restrictFiletype': 1,
                \ 'word': '',
                \ 'replacement': '',
                \ 'flags': '',
                \ 'namedParams': '',
                \ '_init': function('Init'),
                \ 'parseArgs': function('ParseArgs'),
                \ 'hasExtraFlags': {argString -> len(split(argString, ' -')) > 1},
                \ 'handleExtraFlags': function('HandleExtraFlags'),
                \ 'addNamedParameters': function('AddNamedParameters'),
                \ }
    call grepCommand._init()
    return grepCommand
endfunction


function Init() dict abort
    let [self.word, self.replacement, self.flags] = self.parseArgs()
endfunction


function! ParseArgs() dict abort
    if self.hasExtraFlags(self.argString)
        call self.handleExtraFlags()
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


function! HandleExtraFlags() dict abort
    let splitArgs = split(self.argString, ' -')
    let extraFlags = remove(splitArgs, 1, -1)
    if index(extraFlags, 'f') >= 0
        let self.restrictFiletype = 0
    endif
endfunction


function! AddNamedParameters(values, parameter) dict abort
    if type(a:values) != v:t_list
        throw 'ConstructNamedParameters expected type <v:t_list>'
    endif
    if len(a:values) == 0
        return ''
    endif
    for value in a:values
        let self.namedParams = self.namedParams.' --'.a:parameter.'="'.value.'"'
    endfor
endfunction
