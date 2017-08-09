#!/bin/bash

# Do a single out and return saccade.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0

# Negative ThetaX is a downward movement and avoids edge effects in the model.
TARGX=0
TARGY=-10
DISTX=-7
DISTY=-7
FIXLUM=0.2
TARGLUM=0.3
DISTLUM=2
SMALLDISTLUM=1

STARTDIR=`pwd`
mkdir -p results

# Write out a file for veusz to get the target/distractor position from
echo "TX,TY,DX,DY" > results/targets.csv
echo "${TARGX},${TARGY},${DISTX},${DISTY}" >> results/targets.csv

# Write out luminaces file and then run the model.
OMMODEL='TModel4'
OMMPATH="/home/seb/models/OMM_NeuroMuscular/${OMMODEL}"
S2B_DIR='/home/seb/src/SpineML_2_BRAHMS'

#
# First do the distractor run
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${FIXLUM},
     "timeOn":0,"timeOff":0.4},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${TARGLUM},
     "timeOn":0.4,"timeOff":0.8},

     {"shape":"cross","thetaX":${DISTX},"thetaY":${DISTY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${DISTLUM},
     "timeOn":0.5,"timeOff":0.6}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3; do
    # Expt 5 is a 1 second run.
    ./convert_script_s2b -g -m ${OMMPATH} -e9 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_dist_saccsim_side.log
done
popd


#
# Now do some non-distracted runs for comparison
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${FIXLUM},
     "timeOn":0,"timeOff":0.4},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${TARGLUM},
     "timeOn":0.4,"timeOff":0.8}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3; do
    # Expt 5 is a 1 second run.
    ./convert_script_s2b -g -m ${OMMPATH} -e9 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_nodist_saccsim_side.log
done
popd

#
# Finally, medium distracted runs
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${FIXLUM},
     "timeOn":0,"timeOff":0.4},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${TARGLUM},
     "timeOn":0.4,"timeOff":0.8},

     {"shape":"cross","thetaX":${DISTX},"thetaY":${DISTY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":${SMALLDISTLUM},
     "timeOn":0.5,"timeOff":0.6}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3; do
    # Expt 5 is a 1 second run.
    ./convert_script_s2b -g -m ${OMMPATH} -e9 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_mdist_saccsim_side.log
done
popd
