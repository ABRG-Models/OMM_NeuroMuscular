#!/bin/bash

# Do a saccade with a double step.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0

# Negative ThetaX is a downward movement and avoids edge effects in the model.
TARGX=0
TARGY=-8
TARGX2=0
TARGY2=-12

STARTDIR=`pwd`
mkdir -p results

# Write out luminaces file and then run the model.
OMMODEL='TModel4'
OMMPATH="/home/seb/models/OMM_NeuroMuscular/${OMMODEL}"
S2B_DIR='/home/seb/src/SpineML_2_BRAHMS'

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":0.4},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":0.4,"timeOff":0.5},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":0.5,"timeOff":0.8}
 ]
}
EOF

popd

pushd ${S2B_DIR}

for i in 1; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_saccsim_side.log

done