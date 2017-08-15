#!/bin/bash

# Do a single out and return saccade.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0

# Negative ThetaX is a downward movement and avoids edge effects in the model.
TARGX=0
TARGY=-10

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
     "timeOn":0.4,"timeOff":0.8},

     {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,
     "luminance":0.3,
     "timeOn":0.8,"timeOff":2}
 ]
}
EOF

popd

pushd ${S2B_DIR}

for i in 1 2 3 4 5; do
    ./convert_script_s2b -g -m ${OMMPATH} -e8 -o temp/${OMMODEL} \
                         -p "IBN left to FEF Synapse 0 weight_update:w:0" \
                         -p "IBN left to Thalamus Synapse 0 weight_update:w:0" \
                         -p "IBN left to SC_deep Synapse 0 weight_update:w:0" \
                         -p "IBN right to FEF Synapse 0 weight_update:w:0" \
                         -p "IBN right to Thalamus Synapse 0 weight_update:w:0" \
                         -p "IBN right to SC_deep Synapse 0 weight_update:w:0" \
                         -p "IBN up to FEF Synapse 0 weight_update:w:0" \
                         -p "IBN up to Thalamus Synapse 0 weight_update:w:0" \
                         -p "IBN up to SC_deep Synapse 0 weight_update:w:0" \
                         -p "IBN down to FEF Synapse 0 weight_update:w:0" \
                         -p "IBN down to Thalamus Synapse 0 weight_update:w:0" \
                         -p "IBN down to SC_deep Synapse 0 weight_update:w:0"

    # Now extract the movement data and save it off, then re-run several times.
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${i}_saccsim_side.log

done
