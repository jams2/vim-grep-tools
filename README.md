# [vim-supplant](https://github.com/jams2/vim-supplant)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version: 0.1.0](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jams2/vim-super-substitute)


`vim-supplant` is a tool for finding and, optionally, replacing all occurences of a `word` in the current working directory, using the familiar syntax of VIM's `:substitute`. It's a simple wrapper around the usage of grep and the location list. It will ignore files and directories in your .gitignore by default.


## Usage

- Ensure GNU Grep is your grepprg. For OSX users, you could put this in your .vimrc:
```
if executable("ggrep")
    set grepprg=ggrep\ -n
endif
```
- To find and replace all, execute `:Supplant/oldWord/newWord/flags`
    - where flags are `:substitute` compatible.
- To find all, execute `:Supplant/word`
- Default behaviour is to search only in files matching the extension of the current buffer. To disregard filetypes, pass `-f`:
    - `:Supplant/word -f`
- To perform a case-insensitive grep, pass `-i`;
    - `:Supplant/word -i`


## Requirements

### Usage:
- GNU Grep (on OSX, this can be obtained via `brew install grep`)

### Development:
- [Vader](https://github.com/junegunn/vader.vim)
- [covimerage](https://github.com/Vimjas/covimerage)


## Installation

Use [pathogen](https://github.com/tpope/vim-pathogen): `cd ~/.vim/bundle && git clone https://github.com/jams2/vim-supplant.git`


## Configuration

- To add default excluded directories (passed as `--exclude-dir` options to grep);
    - `let g:supplantExcludeDirs = ['exclude_me', 'and_me']`
- To add default excluded files (passed as `--exclude` options to grep);
    - `let g:supplantExcludeFiles = ['exclude_me', 'and_me']`
- To bypass gitignore parsing;
    - `let g:supplantParseGitIgnore = 0`


I have the following in my .vimrc:
```
nnoremap <leader>yg "pyiw :Supplant/<C-r>p/
vnoremap <leader>yg "py :Supplant/<C-r>p/
```
