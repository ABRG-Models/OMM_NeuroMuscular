#!/bin/sh

# This script finds which runs from a weight finding session failed to
# complete. Made obsolete by the fact that the Iceberg settings are
# now good and the weight training runs complete reliably.

for i in runwf3dmany*.out; do
    tail -n 50 "$i" | grep Overall > /dev/null 2>&1
    rtn=$?
    if [ $rtn == "1" ]; then
        # Then this one doesn't contain the "Overall best weights"
        # line and needs to be re-computed.
        echo -n "$i " |  sed 's/runwf3dmany//g' | tr --delete ".out"
    fi
done
