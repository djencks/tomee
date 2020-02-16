#!/bin/bash

# This meta-script generates a script to copy the example README.adoc files in each language to an Antora component/version structure.
# The generated script can be modified by hand and checked in to track changes.

echo "Run this script only from the docs/ directory!"

examples=../examples

#English to start with...

for language in en es pt
do

if [[ $language != "en" ]]
then
    suffix="_$language"
fi

script=copy-examples-$language.sh

targetDir=examples-$language/modules/ROOT
mkdir -p $targetDir/

echo "#!/bin/bash

mkdir -p $targetDir/pages

cp $examples/README.adoc $targetDir/pages/index.adoc

" >$script

navFile=$targetDir/nav.adoc
echo "// generated examples file" > $navFile

for readme in `find $examples -mindepth 2 -name "README$suffix.adoc" | sort`
do
#    echo $readme
    stem=`echo  $readme |sed -E "s/\.\.\/examples\/(.*)\/README$suffix.adoc/\1/"`
#    echo $stem
    targetFile=${stem}.adoc
#    echo $targetFile
    targetLoc=$targetDir/pages/$targetFile
#    echo $targetLoc
#    echo "cp $readme $targetLoc"
    echo "cp $readme $targetLoc" >> $script
    echo "* xref:$targetFile[$stem]" >> $navFile
done

chmod u+x $script

#echo "navFile $navFile"

done
