#!/bin/bash

# Replace various utf-8 characters with the tex/latex equivalents
# because Frontiers doesn't like utf-8 in .bbl files.

if [ -z ${1} ]; then
    echo "Please supply path to the .bbl file"
    exit 1
fi

mkdir -p /tmp/utf8tolatex
e=$?
if [ ${e} -ne "0" ]; then
    echo "Failed to make /tmp/utf8tolatex dir. Exiting."
    exit 1
fi

# Backup
cp ${1} /tmp/utf8tolatex/${1}.backup
e=$?
if [ ${e} -ne "0" ]; then
    echo "Failed to make backup. Exiting."
    exit 1
fi

# Search/replace u umlauts
sed 's/\xc3\xbc/\\"u/g' < "$1" > /tmp/utf8tolatex/1.bbl

# e acute (Moren)
sed 's/\xc3\xa9/\\'\''e/g' < /tmp/utf8tolatex/1.bbl >  /tmp/utf8tolatex/2.bbl

# e grave (Lefevre)
sed 's/\xc3\xa8/\\\`e/g' < /tmp/utf8tolatex/2.bbl >  /tmp/utf8tolatex/3.bbl

# Reg
sed 's/\xc2\xae/\\textsuperscript\{\\textregistered\}/g' < /tmp/utf8tolatex/3.bbl >  /tmp/utf8tolatex/4.bbl

# TM
sed 's/\xe2\x84\xa2/\\textsuperscript\{TM\}/g' < /tmp/utf8tolatex/4.bbl >  /tmp/utf8tolatex/5.bbl

# Copy back
cp /tmp/utf8tolatex/5.bbl ${1}
