#!/bin/sh

covimerage run --no-report vim -Nu test/vimrc -c 'Vader! test/testSupplanter.vader'
covimerage -vv xml
covimerage report -m
