let s:MAX_COMMAND_ARGS = 3


function supplanter#Supplanter(argString) abort
    let l:supplanter = {
                \ 'argString': a:argString,
                \ 'grepCommand': 0,
                \ 'shouldReplaceMatches': 0,
                \ 'word': '',
                \ 'replacement': '',
                \ 'substituteFlags': '',
                \ 'grepCaseSensitivity': 1,
                \ 'grepMatchFileExtension': 1,
                \ '_init': function('s:InitSupplanter'),
                \ '_parseAndRemoveModifiers':
                    \ function('s:ParseAndRemoveModifiers'),
                \ '_hasModifiers': function('s:HasModifiers'),
                \ '_parseModifiers': function('s:ParseModifiers'),
                \ '_removeModifiersFromArgString':
                    \ function('s:RemoveModifiersFromArgString'),
                \ '_parseArgs': function('s:ParseArgs'),
                \ '_validateArgs': function('s:ValidateArgs'),
                \ '_initGrepCommand': function('s:InitGrepCommand'),
                \ '_hasReplacementParams': function('s:HasReplacementParams'),
                \ }
    call l:supplanter._init()
    return l:supplanter
endfunction


function s:InitSupplanter() dict abort
    call self._parseAndRemoveModifiers()
    call self._parseArgs()
    let self.grepCommand = self._initGrepCommand()
    call self.grepCommand.setCaseSensitivity(self.grepCaseSensitivity)
    call self.grepCommand.setLimitsResultsPerFile(self._hasReplacementParams())
endfunction


function s:ParseAndRemoveModifiers() dict abort
    if self._hasModifiers()
        call self._parseModifiers()
        call self._removeModifiersFromArgString() 
    endif
endfunction


function s:HasModifiers() dict abort
    return len(split(self.argString, ' -')) > 1
endfunction


function s:ParseModifiers() dict abort
    let splitArgs = split(self.argString, ' -')
    let extraFlags = remove(splitArgs, 1, -1)
    " handle bunched flags, like -fi
    if index(extraFlags, 'f') >= 0
        let self.grepMatchFileExtension = 0
    elseif index(extraFlags, 'i') >= 0
        let self.grepCaseSensitivity = 0
    endif
endfunction


function s:RemoveModifiersFromArgString() dict abort
    let self.argString = split(self.argString, ' -')[0]
endfunction


function s:ParseArgs() dict abort
    let l:args = split(self.argString, '/')
    call self._validateArgs(l:args)
    while s:MAX_COMMAND_ARGS - len(l:args) > 0
        let l:args += ['']
    endwhile
    let [self.word, self.replacement, self.substituteFlags] = l:args
endfunction


function s:ValidateArgs(args) dict abort
    if len(a:args) > s:MAX_COMMAND_ARGS
        throw 'Supplanter: Invalid :substitute string'
    endif
endfunction


function s:InitGrepCommand() dict abort
    let l:grepCommand = grepcommand#GrepCommand(self.word)
    return l:grepCommand
endfunction


function s:HasReplacementParams() dict abort
    return self.replacement != '' && self.flags != ''
endfunction
