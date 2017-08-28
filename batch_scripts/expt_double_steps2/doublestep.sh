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

TARGT=0.4
TARGT2=0.43 # 0.43: Single sacc, 0.44: Double step

STARTDIR=`pwd`
mkdir -p results

# Write out luminaces file and then run the model.
OMMODEL='TModel5'
OMMPATH="/home/seb/models/OMM_NeuroMuscular/${OMMODEL}"
S2B_DIR='/home/seb/src/SpineML_2_BRAHMS'

#
# First job: Do single saccades to 8 degrees and 12 degrees.
#
pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_targ1_ss.log
done
popd

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_targ2_ss.log
done
popd

#
# Now do small to large with 0.03 s gap
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":${TARGT2}},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT2},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_smalllarge_0.03_saccsim_side.log
done
popd


#
# Now do large to small with 0.03 s gap
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":${TARGT2}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT2},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_largesmall_0.03_saccsim_side.log
done
popd

#
# Now do small to large with 0.04 s gap
#
TARGT2=0.44

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":${TARGT2}},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT2},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_smalllarge_0.04_saccsim_side.log
done
popd


#
# Now do large to small with 0.04 s gap
#

pushd ${OMMPATH}
cat > luminances.json <<EOF
{"luminances":
 [
    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.200000,
     "timeOn":0,"timeOff":${TARGT}},

     {"shape":"cross","thetaX":${TARGX2},"thetaY":${TARGY2},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT},"timeOff":${TARGT2}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":${TARGT2},"timeOff":100}
 ]
}
EOF
popd

pushd ${S2B_DIR}
for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL}
    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_largesmall_0.04_saccsim_side.log
done
popd
