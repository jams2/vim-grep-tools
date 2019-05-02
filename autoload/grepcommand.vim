function! grepcommand#GrepCommand(word) abort
    let l:grepCommand = {
                \ 'word': a:word,
                \ '_namedParams': '',
                \ '_command': '',
                \ '_isCaseSensitive': 1,
                \ '_limitsResultsPerFile': 1,
                \ '_grepFlags': '',
                \ '_getGrepPrg': function('s:GetGrepPrg'),
                \ '_getGrepFlags': function('s:GetGrepFlags'),
                \ '_getGrepPattern': function('s:GetGrepPattern'),
                \ 'setCaseSensitivity': function('s:SetCaseSensitivity'),
                \ 'setLimitsResultsPerFile': function('s:SetLimitsResultsPerFile'),
                \ 'addNamedParameters': function('s:AddNamedParameters'),
                \ 'toString': function('s:ToString'),
                \ }
    return l:grepCommand
endfunction


function s:InitGrepCommand() dict abort
    let self._command = self._getGrepPrg()
    let self._grepPattern = self._getGrepPattern()
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
    return ' "\b' . self.word . '/b"'
endfunction


function s:SetCaseSensitivity(isCaseSensitive) dict abort
    let self._isCaseSensitive = a:isCaseSensitive
endfunction


function s:SetLimitsResultsPerFile(limitsResultsPerFile) dict abort
    let self._limitsResultsPerFile = a:limitsResultsPerFile
endfunction


function s:AddNamedParameters(values, parameter) dict abort
    if type(a:values) != v:t_list
        throw 'ConstructNamedParameters expected type <v:t_list>'
    endif
    if len(a:values) == 0
        return ''
    endif
    for value in a:values
        let self._namedParams = self._namedParams . ' --' . a:parameter .'="'
        let self._namedParams = self._namedParams . value . '"'
    endfor
endfunction


function s:ToString() dict abort
    let asString = self._getGrepPrg() . self._getGrepFlags() .
                \ self._getGrepPattern() . self._namedParams
    return asString
endfunction
