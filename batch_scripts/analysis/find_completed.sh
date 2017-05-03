#!/bin/sh

# A script to find how many of the weight finding runs worked. This is
# made obsolete by the fact that I got the Iceberg settings set up so
# that allt he runs now work (and they email if they abort for any
# reason).

for i in runwf3dmany*.out; do
    tail -n 50 "$i" | grep Overall > /dev/null 2>&1
    rtn=$?
    if [ $rtn == "0" ]; then
        # Then this one does contain the "Overall best weights"
        echo -n "$i " |  sed 's/runwf3dmany//g' | tr --delete ".out"
    fi
done
