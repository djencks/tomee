#!/bin/bash

# This meta-script generates a script to copy the example README.adoc files in each language to an Antora component/version structure.
# The generated script can be modified by hand and checked in to track changes.

EXAMPLES=../examples

#English to start with...

SCRIPT=move-examples-en.sh

TARGET_DIR=examples-en/modules/ROOT
mkdir -p $TARGET_DIR/

echo "#!/bin/bash

mkdir -p $TARGET_DIR/pages

" >$SCRIPT

navFile=$TARGET_DIR/nav.adoc
rm $navFile
touch $navFile

for readme in `find $EXAMPLES -name "README.adoc" | sort`
do
#    echo $readme
    stem=`echo  $readme |sed -E "s/\.\.\/examples\/(.*)\/README.adoc/\1/"`
#    echo $stem
    targetFile=${stem}.adoc
#    echo $targetFile
    targetLoc=$TARGET_DIR/$targetFile
#    echo $targetLoc
#    echo "cp $readme $targetLoc"
    echo "cp $readme $targetLoc" >> $SCRIPT
    echo "* xref:$targetFile[$stem]" >> $navFile
done

chmod u+x $SCRIPT

#echo "navFile $navFile"
