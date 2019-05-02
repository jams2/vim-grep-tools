let s:MAX_COMMAND_ARGS = 3


function supplanter#Supplanter(argString) abort
    let l:supplanter = {
                \ 'argString': a:argString,
                \ 'grepCommand': 0,
                \ 'shouldReplaceMatches': 0,
                \ 'word': '',
                \ 'replacement': '',
                \ 'substituteFlags': '',
                \ 'grepIgnoreCase': 0,
                \ 'grepMatchFileExtension': 1,
                \ '_init': function('s:InitSupplanter'),
                \ '_parseAndRemoveModifiers': function('s:ParseAndRemoveModifiers'),
                \ '_hasModifiers':
                    \ {argString -> len(split(argString, ' -')) > 1},
                \ '_parseModifiers': function('s:ParseModifiers'),
                \ '_removeModifiersFromArgString':
                    \ function('s:RemoveModifiersFromArgString'),
                \ '_parseArgs': function('s:ParseArgs'),
                \ '_validateArgs': function('s:ValidateArgs'),
                \ '_initGrepCommand': function('s:InitGrepCommand'),
                \ }
    call l:supplanter._init()
    return l:supplanter
endfunction


function s:InitSupplanter() dict abort
    call self._parseAndRemoveModifiers()
    call self._parseArgs()
    let self.grepCommand = self._initGrepCommand()
endfunction


function s:ParseAndRemoveModifiers() dict abort
    if self._hasModifiers()
        call self._parseModifiers()
        call self._removeModifiersFromArgString() 
    endif
endfunction


function s:ParseModifiers() dict abort
    let splitArgs = split(self.argString, ' -')
    let extraFlags = remove(splitArgs, 1, -1)
    " handle bunched flags, like -fi
    if index(extraFlags, 'f') >= 0
        let self.grepMatchFileExtension = 0
    elseif index(extraFlags, 'i') >= 0
        let self.grepIgnoreCase = 0
    endif
endfunction


function s:RemoveModifiersFromArgString() dict abort
    let self.argString = split(self.argString, ' -')[0]
endfunction


function s:ParseArgs() dict abort
    let l:args = split(self.argString, '/')
    call self._validateArgs()
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
endfunction
