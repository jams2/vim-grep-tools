" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
"
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


if v:version < 700
    echomsg 'supplant requires VIM >= 700'
elseif exists('g:loadedSupplant')
    finish
endif
let g:loadedSupplant = 1

if !exists('g:supplantParseGitIgnore')
    let g:supplantParseGitIgnore = 1
endif

if g:supplantParseGitIgnore && !exists('g:gitIgnoreFiles') && !exists('g:gitIgnoreDirs')
    let [g:gitIgnoreFiles, g:gitIgnoreDirs] = getgitignore#GetFilesAndDirs()
endif

if !exists('g:supplantIgnoreFiles')
    let g:supplantIgnoreFiles = []
endif

if !exists('g:supplantIgnoreDirs')
    let g:supplantIgnoreDirs = []
endif


command! -nargs=1 Supplant :call supplant#Supplant(<q-args>)
