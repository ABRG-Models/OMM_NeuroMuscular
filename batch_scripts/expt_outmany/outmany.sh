#!/bin/bash

# Do several single out saccades to different locations for plotting RX/RY.

# Negative ThetaX is a downward movement and avoids edge effects in the model.
FIXLUM=0.2
TARGLUM=0.3

STARTDIR=`pwd`
mkdir -p results

# Write out a file for veusz to get the target positions from
echo "TX,TY" > results/targets.csv

# Write out luminaces file and then run the model.
OMMODEL='TModel4'
OMMPATH="${HOME}/OMM_NeuroMuscular/${OMMODEL}"
S2B_DIR="${HOME}/SpineML_2_BRAHMS"

#
# Five outward saccades, ready for plotting.
#

LIST="RX0RY-10 RX-7RY-7 RX-10RY0 RX-7RY7 RX0RY10"
LIST="${LIST} RX-3RY-5 RX-3RY5 RX-8RY-5 RX-8RY5"

for tag in $LIST; do

    tx=`echo $tag | awk -F 'R' '{print $2}' | tr --delete "X"`
    ty=`echo $tag | awk -F 'R' '{print $3}' | tr --delete "Y"`

    echo "${tx},${ty}" >> results/targets.csv

    pushd ${OMMPATH}
    cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${FIXLUM},
     "timeOn":0,"timeOff":0.4},

     {"shape":"cross","thetaX":${tx},"thetaY":${ty},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${TARGLUM},
     "timeOn":0.4,"timeOff":0.8}
 ]
}
EOF
    popd

    pushd ${S2B_DIR}
    # Expt 5 is a 1 second run.
    ./convert_script_s2b -g -m ${OMMPATH} -e9 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/RX${tx}_RY${ty}_saccsim_side.log
    popd

done
