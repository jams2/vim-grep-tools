let s:MAX_COMMAND_ARGS = 3


function! GrepCommand(argString) abort
    let grepCommand = {
                \ 'argString': a:argString,
                \ 'restrictFiletype': 1,
                \ 'grepMaxCount': 0,
                \ 'ignoreCase': 0,
                \ 'word': '',
                \ 'replacement': '',
                \ 'flags': '',
                \ 'namedParams': '',
                \ '_command': '',
                \ '_init': function('Init'),
                \ '_parseArgs': function('ParseArgs'),
                \ '_isSearchOnly': {-> self.replacement == '' && self.flags == ''},
                \ '_getGrepPrg': function('GetGrepPrg'),
                \ '_getGrepFlags': function('GetGrepFlags'),
                \ '_hasExtraFlags': {argString -> len(split(argString, ' -')) > 1},
                \ '_handleExtraFlags': function('HandleExtraFlags'),
                \ 'addNamedParameters': function('AddNamedParameters'),
                \ 'toString': function('ToString'),
                \ }
    call grepCommand._init()
    return grepCommand
endfunction


function Init() dict abort
    let [self.word, self.replacement, self.flags] = self._parseArgs()
    let self.grepMaxCount = self._isSearchOnly() ? 0 : 1
    let self._command = self._getGrepPrg() . self._getGrepFlags()
endfunction


function! ParseArgs() dict abort
    if self._hasExtraFlags(self.argString)
        call self._handleExtraFlags()
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
    " handle bunched flags, like -ri
    if index(extraFlags, 'f') >= 0
        let self.restrictFiletype = 0
    else if index(extraFlags, 'i') >= 0
        let self.ignoreCase = 0
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


function! ToString() dict abort
endfunction


function! GetGrepPrg() dict abort
    return &grepprg
endfunction


function! GetGrepFlags() dict abort
    let flags = self.ignoreCase ? ' -ri' : ' -r'
    if self.grepMaxCount
        let flags = flags.' -m1'
    endif
    let flags = flags.' -e'
    return flags
endfunction
