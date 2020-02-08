#!/bin/bash

# This is how I compared contents of old and current sites.

# extract <loc> lines from old sitemap.xml
curl https://tomee.apache.org/sitemap.xml >old-sitemap.xml
grep '<loc>' old-sitemap.xml |sed -E "s/.*(http.*html).*/\1/g" |sort >old-sitemap-addr.txt

# extract <loc> lines from new sitemap.xml
grep '<loc>' build/site/sitemap-*.xml |sed -E "s/.*(http.*html).*/\1/g" |sort >new-sitemap-addr.txt

# Remove initial segment, repeating full address at end.
#cat old-sitemap-addr.txt |sed -E "s/(http\:\/\/tomee\.apache\.org\/(.*.html))/\2        \1/g" |sort >old-sitemap-index.txt
cat old-sitemap-addr.txt |sed -E "s/(http\:\/\/tomee\.apache\.org.*\/(.*.html))/\2        \1/g"|grep -v "^README.html" | sort >old-sitemap-index-a.txt
cat old-sitemap-addr.txt |sed -E "s/(http\:\/\/tomee\.apache\.org\/examples\/(.*)\/README.html)/\2.html        \1/g"|grep "   " | sort >old-sitemap-index-b.txt
sort old-sitemap-index-a.txt old-sitemap-index-b.txt > old-sitemap-index.txt
#cat new-sitemap-addr.txt |sed -E "s/(https\:\/\/tomee\.apache\.org\/Tomee\/([[:digit:]]\.[[:digit:]])\/(.*.html))/\3      \2        \1/g" |sort >new-sitemap-index.txt
cat new-sitemap-addr.txt |sed -E "s/(https\:\/\/tomee\.apache\.org\/(Tomee|examples)\/([[:digit:]]\.[[:digit:]]).*\/(.*.html))/\4      \3        \1/g"|sort >new-sitemap-index.txt

#Get just the names (first field in "record") for use in grep "not in the other file"
cat old-sitemap-index.txt |sed -E "s/(^.*.html).*http.*\.html/\1/g"|sort >old-sitemap-names.txt
cat new-sitemap-index.txt |sed -E "s/(^.*.html).*http.*\.html/\1/g"|sort >new-sitemap-names.txt

# Use grep to find the ones missing in the other file
grep -vf old-sitemap-names.txt new-sitemap-index.txt >new-not-old-index-all.txt
grep -E -v "_es.html|_pt.html" new-not-old-index-all.txt >new-not-old-index.txt
grep -vf new-sitemap-names.txt old-sitemap-index.txt >old-not-new-index.txt

