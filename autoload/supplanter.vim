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
                \ 'shouldMatchFileExtension': 1,
                \ '_Init': function('s:InitSupplanter'),
                \ '_ParseAndRemoveModifiers':
                    \ function('s:ParseAndRemoveModifiers'),
                \ '_HasModifiers': function('s:HasModifiers'),
                \ '_ParseModifiers': function('s:ParseModifiers'),
                \ '_RemoveModifiersFromArgString':
                    \ function('s:RemoveModifiersFromArgString'),
                \ '_ParseArgs': function('s:ParseArgs'),
                \ '_ValidateArgs': function('s:ValidateArgs'),
                \ '_InitGrepCommand': function('s:InitGrepCommand'),
                \ '_HasReplacementParams': function('s:HasReplacementParams'),
                \ 'AddExcludeDirGlobs': function('s:AddExcludeDirGlobs'),
                \ 'AddExcludeGlobs': function('s:AddExcludeGlobs'),
                \ 'AddIncludeGlobs': function('s:AddIncludeGlobs'),
                \ }
    call l:supplanter._Init()
    return l:supplanter
endfunction


function s:InitSupplanter() dict abort
    call self._ParseAndRemoveModifiers()
    call self._ParseArgs()
    let self.grepCommand = self._InitGrepCommand()
    call self.grepCommand.SetCaseSensitivity(self.grepCaseSensitivity)
    call self.grepCommand.SetLimitsResultsPerFile(self._HasReplacementParams())
endfunction


function s:ParseAndRemoveModifiers() dict abort
    if self._HasModifiers()
        call self._ParseModifiers()
        call self._RemoveModifiersFromArgString() 
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
        let self.shouldMatchFileExtension = 0
    elseif index(extraFlags, 'i') >= 0
        let self.grepCaseSensitivity = 0
    endif
endfunction


function s:RemoveModifiersFromArgString() dict abort
    let self.argString = split(self.argString, ' -')[0]
endfunction


function s:ParseArgs() dict abort
    let l:args = split(self.argString, '/')
    call self._ValidateArgs(l:args)
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
    return self.replacement != '' && self.substituteFlags != ''
endfunction


function s:AddExcludeGlobs(globs) dict abort
    if type(a:globs) != v:t_list
        throw 'AddExcludeGlobs expected type <v:t_list>'
    endif
    call self.grepCommand.AddNamedParameters('exclude', a:globs)
endfunction


function s:AddExcludeDirGlobs(globs) dict abort
    if type(a:globs) != v:t_list
        throw 'AddExcludeDirGlobs expected type <v:t_list>'
    endif
    call self.grepCommand.AddNamedParameters('exclude-dir', a:globs)
endfunction


function s:AddIncludeGlobs(globs) dict abort
    if type(a:globs) != v:t_list
        throw 'AddIncludeGlobs expected type <v:t_list>'
    endif
    call self.grepCommand.AddNamedParameters('include', a:globs)
endfunction
