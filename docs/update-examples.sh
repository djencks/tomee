#!/bin/bash

# This is a "do-it-all" script for updating the examples in the local filesystem

#clean old .adoc files
rm -rf ./examples-en/modules/ROOT/pages ./examples-es/modules/ROOT/pages ./examples-pt/modules/ROOT/pages

# create up to date scripts
./create-example-script.sh

# run them
./copy-examples-en.sh
./copy-examples-es.sh
./copy-examples-pt.sh

#show changes
git status .
