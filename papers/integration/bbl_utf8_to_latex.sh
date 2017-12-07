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

count=0

# Search/replace u umlauts
sed 's/\xc3\xbc/\\"u/g' < "$1" > /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# Search/replace U umlauts
sed 's/\xc3\x9c/\\"U/g' < /tmp/utf8tolatex/${count}.bbl > /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# o umlaut
sed 's/\xc3\xb6/\\"o/g' < /tmp/utf8tolatex/${count}.bbl > /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# O umlaut
sed 's/\xc3\x96/\\"O/g' < /tmp/utf8tolatex/${count}.bbl > /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# e acute (Moren)
sed 's/\xc3\xa9/\\'\''e/g' < /tmp/utf8tolatex/${count}.bbl >  /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# e grave (Lefevre)
sed 's/\xc3\xa8/\\\`e/g' < /tmp/utf8tolatex/${count}.bbl >  /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# Reg
sed 's/\xc2\xae/\\textsuperscript\{\\textregistered\}/g' < /tmp/utf8tolatex/${count}.bbl >  /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))

# TM
sed 's/\xe2\x84\xa2/\\textsuperscript\{TM\}/g' < /tmp/utf8tolatex/${count}.bbl >  /tmp/utf8tolatex/$((count+1)).bbl
count=$((count+1))


# Copy back
cp /tmp/utf8tolatex/${count}.bbl ${1}
