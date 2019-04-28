#!/usr/bin/sh

covimerage run --no-report vim -Nu test/vimrc -c 'Vader! test/*'
covimerage -vv xml
covimerage report -m
