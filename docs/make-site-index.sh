#!/bin/bash

# process new-sitemap-index.txt into source file name to antora content id

#sed -E  "s/(.*).html *(:[digit]:\.:[digit]) *https:\/\/tomee.apache.org\/(tomee|examples)\/:[digit]:\.:[digit]:\/(.*).html$/\1.adoc \2@\3::\4.adoc/g" <new-sitemap-index.txt > new-antora-index.txt

sed -E  "s/(.*).html *([^ ]*) *https:\/\/tomee.apache.org\/(tomee|examples)\/(.\..(_..)?)\/(.*).html$/\1.adoc \4@\3::\6.adoc/g" <new-sitemap-index.txt  > new-antora-index.txt
