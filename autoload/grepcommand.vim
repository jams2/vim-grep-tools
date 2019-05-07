let s:CWD = ' .'


function! grepcommand#GrepCommand(word) abort
    let l:grepCommand = {
                \ 'word': a:word,
                \ '_namedParams': '',
                \ '_command': '',
                \ '_isCaseSensitive': 1,
                \ '_limitsResultsPerFile': 1,
                \ '_grepFlags': '',
                \ '_GetGrepPrg': function('s:GetGrepPrg'),
                \ '_GetGrepFlags': function('s:GetGrepFlags'),
                \ '_GetGrepPattern': function('s:GetGrepPattern'),
                \ 'SetCaseSensitivity': function('s:SetCaseSensitivity'),
                \ 'SetLimitsResultsPerFile': function('s:SetLimitsResultsPerFile'),
                \ 'AddNamedParameters': function('s:AddNamedParameters'),
                \ 'ToString': function('s:ToString'),
                \ }
    return l:grepCommand
endfunction


function s:InitGrepCommand() dict abort
    let self._command = self._GetGrepPrg()
    let self._grepPattern = self._GetGrepPattern()
endfunction


function s:GetGrepPrg() dict abort
    return &grepprg
endfunction


function s:GetGrepFlags() dict abort
    let l:flags = self._isCaseSensitive ? ' -r' : ' -ri'
    let l:flags = self._limitsResultsPerFile ? l:flags . ' -m1' : l:flags
    let l:flags = l:flags . ' -e'
    return l:flags
endfunction


function s:GetGrepPattern() dict abort
    return ' "\b' . self.word . '\b"'
endfunction


function s:SetCaseSensitivity(isCaseSensitive) dict abort
    let self._isCaseSensitive = a:isCaseSensitive
endfunction


function s:SetLimitsResultsPerFile(limitsResultsPerFile) dict abort
    let self._limitsResultsPerFile = a:limitsResultsPerFile
endfunction


function s:AddNamedParameters(parameter, values) dict abort
    if type(a:values) != v:t_list
        throw 'ConstructNamedParameters expected type <v:t_list>'
    endif
    if len(a:values) == 0
        return
    endif
    for value in a:values
        let self._namedParams = self._namedParams . ' --' . a:parameter .'="'
        let self._namedParams = self._namedParams . value . '"'
    endfor
endfunction


function s:ToString() dict abort
    let asString = self._GetGrepPrg() . self._GetGrepFlags() .
                \ self._GetGrepPattern() . s:CWD . self._namedParams
    return asString
endfunction
