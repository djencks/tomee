#!/bin/bash

grep -l -R "link:" tomee | xargs -n 1 sed -E -i x "s/link:([^h][^t][^\[]*).html/xref:\1.adoc/g"

find . -name "*.adocx" |xargs rm
