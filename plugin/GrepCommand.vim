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
                \ '_grepFlags': '',
                \ '_init': function('Init'),
                \ '_parseArgs': function('ParseArgs'),
                \ '_isSearchOnly': function('IsSearchOnly'),
                \ '_getGrepPrg': function('GetGrepPrg'),
                \ '_getGrepFlags': function('GetGrepFlags'),
                \ '_getGrepPattern': function('GetGrepPattern'),
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
    echo self.flags
    let self.grepMaxCount = self._isSearchOnly() ? 0 : 1
    let self._command = self._getGrepPrg()
    let self._grepFlags = self._getGrepFlags()
    let self._grepPattern = self._getGrepPattern()
    echo self.flags
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


function! IsSearchOnly() dict abort
    return self.replacement == '' && self.flags == ''
endfunction


function! HandleExtraFlags() dict abort
    let splitArgs = split(self.argString, ' -')
    let extraFlags = remove(splitArgs, 1, -1)
    echo extraFlags
    " handle bunched flags, like -ri
    if index(extraFlags, 'f') >= 0
        let self.restrictFiletype = 0
    elseif index(extraFlags, 'i') >= 0
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
    return self._command . self._grepFlags . self._grepPattern . self.namedParams
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

function! GetGrepPattern() dict abort
    return ' "\b' . self.word . '/b"'
endfunction
