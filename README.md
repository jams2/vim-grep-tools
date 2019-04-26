# vim-grep-tools

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Version: 0.1.0](https://img.shields.io/badge/version-0.1.0-brightgreen.svg)](https://github.com/jams2/vim-grep-tools)


A collection of small tools to make the use of grep within a project more convenient.


While using VIM as my primary text editor (working predominantly on a Django/ReactJS web application), I find myself often using grep from within VIM to find all occurences of a word. To find all occurences in the project directory, I would end up typing:


`:grep -ri "\bSomeClassName\b" . --include="*.py" --exclude-dir="staticfiles" --exclude-dir="node_modules"`


That's 105 keystrokes. That should be automated. So, as the story goes, it ends up in my .vimrc. Then, the inevitable .vimrc bloat increases, so it ends up becoming a plugin, and here we are.


This is a simple tool with narrow scope. If someone finds it useful, that's fantastic. Please raise issues and requests and I'll do my best to deal with them.
