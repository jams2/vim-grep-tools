# [vim-supplant](https://github.com/jams2/vim-supplant)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version: 0.1.0](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jams2/vim-super-substitute)


`vim-supplant` is a tool for replacing all occurences of a word in the current working directory, using the familiar syntax of VIM's `:substitute`.


While using VIM as my primary text editor, I often find myself using `:grep` to find all occurences of a word. I will execute something like;


`:grep -ri "\bSomeClassName\b" . --include="*.py" --exclude-dir="staticfiles" --exclude-dir="node_modules"`


... followed by;


`:cdo s/\<SomeClassName\>/NewClassName/g`


That's 144 keystrokes, and should be automated.


This is a simple tool with narrow scope. If someone else finds it useful, that's fantastic. Feel free to raise issues and requests and I'll do my best to deal with them.



## Requirements

- GNU Grep (on OSX, this can be obtained via `brew install grep`)
- [Vader](https://github.com/junegunn/vader.vim) (testing)



## Usage

- Ensure GNU Grep is your grepprg. For OSX users, you could put this in your .vimrc:
    ```
    if executable("ggrep")
        set grepprg=ggrep\ -n
    endif
    ```
- To find and replace all, execute `:Supplant/oldWord/newWord/flags`
    - where flags are `:substitute` compatible.
- To find all, execute `:SupplantFindAll word`



## Configuration

- To add default excluded directories (passed as `--exclude-dir` options to grep);
    - `let g:supplantExcludeDirs = ['exclude_me', 'and_me']`
- To set case-sensitivity;
    - `let g:supplantIgnoreCase = 0` (in {0, 1})


Suggested mappings:
```
nnoremap <leader>yg "pyiw :Supplant/<C-r>p
vnoremap <leader>yg "py :Supplant/<C-r>p
nnoremap <leader>ff "pyiw :SupplantFindAll <C-r>p<CR>
vnoremap <leader>ff "py :SupplantFindAll <C-r>p<CR>
```
