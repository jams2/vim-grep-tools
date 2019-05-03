" supplant.vim - use grep to :substitute across files
" Author:   Joshua Munn <https://www.joshuamunn.com>
" Version:  0.1.0
"
" When constructing strings that might be concatenated together, stick
" to a leading-space convention.


" if exists('g:loadedSupplant')
"     finish
" endif


command! -nargs=1 Supplant :call supplant#Supplant(<q-args>)
