let s:MAX_COMMAND_ARGS = 3


function! grepcommand#GrepCommand(argString) abort
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
                \ '_init': function('s:InitGrepCommand'),
                \ '_parseArgs': function('s:ParseArgs'),
                \ 's:HasReplacementParams': function('s:HasReplacementParams'),
                \ '_getGrepPrg': function('s:GetGrepPrg'),
                \ '_getGrepFlags': function('s:GetGrepFlags'),
                \ '_getGrepPattern': function('s:GetGrepPattern'),
                \ '_hasModifiers':
                    \ {argString -> len(split(argString, ' -')) > 1},
                \ '_parseModifiers': function('s:ParseModifiers'),
                \ '_removeModifiersFromArgString':
                    \ function('s:RemoveModifiersFromArgString'),
                \ 's:AddNamedParameters': function('s:AddNamedParameters'),
                \ 's:ToString': function('s:ToString'),
                \ }
    call grepCommand._init()
    return grepCommand
endfunction


function s:InitGrepCommand() dict abort
    let [self.word, self.replacement, self.flags] = self._parseArgs()
    echo self.flags
    call self.s:SetCaseSensitivityFromGlobal()
    let self.grepMaxCount = self.s:HasReplacementParams() ? 1 : 0
    let self._command = self._getGrepPrg()
    let self._grepFlags = self._getGrepFlags()
    let self._grepPattern = self._getGrepPattern()
endfunction


function s:ParseArgs() dict abort
    if self._hasModifiers(self.argString)
        call self._parseModifiers()
        call self._removeModifiersFromArgString()
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


function s:ParseModifiers() dict abort
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


function s:RemoveModifiersFromArgString() dict abort
    let self.argString = split(self.argString, ' -')[0]
endfunction


function s:SetCaseSensitivityFromGlobal() dict abort
    if exists('g:supplantIgnoreCase')
        let self.ignoreCase = g:supplantIgnoreCase
    else
        let self.ignoreCase = 0
    endif
endfunction


function s:HasReplacementParams() dict abort
    return self.replacement != '' && self.flags != ''
endfunction


function s:AddNamedParameters(values, parameter) dict abort
    if type(a:values) != v:t_list
        throw 'ConstructNamedParameters expected type <v:t_list>'
    endif
    if len(a:values) == 0
        return ''
    endif
    for value in a:values
        let self.namedParams = self.namedParams . ' --' . a:parameter .'="'
        let self.namedParams = self.namedParams . value . '"'
    endfor
endfunction


function s:ToString() dict abort
    let asString = self._command . self._grepFlags . self._grepPattern
    return asString . self.namedParams
endfunction


function s:GetGrepPrg() dict abort
    return &grepprg
endfunction


function s:GetGrepFlags() dict abort
    let flags = self.ignoreCase ? ' -ri' : ' -r'
    if self.grepMaxCount
        let flags = flags . ' -m1'
    endif
    let flags = flags . ' -e'
    return flags
endfunction

function s:GetGrepPattern() dict abort
    return ' "\b' . self.word . '/b"'
endfunction
