#!/bin/bash

# Copy source for inclusion in .adoc files.
# At the moment this script must be maintained manually.

mkdir -p examples-en/modules/ROOT/examples

cp -r ../examples/groovy-jpa/src examples-en/modules/ROOT/examples
cp -r ../examples/groovy-spock/src examples-en/modules/ROOT/examples
