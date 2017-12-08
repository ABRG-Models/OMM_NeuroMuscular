#!/bin/bash

# This converts all the .pngs (which can't be submitted to Frontiers)
# in the parent figures directory into tiff files (which can).  The
# -flatten option to convert makes sure to replace any transparency in
# the png with the background white colour.

for i in ../*.png; do
    convert -flatten "${i}" ${i}.tiff
done

mv ../*.png.tiff .
