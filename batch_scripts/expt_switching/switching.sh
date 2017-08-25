#!/bin/bash

# Do a single out and return saccade.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0

# Negative ThetaX is a downward movement and avoids edge effects in the model.
TARGX=0
TARGY=-10
TARG2X=0
TARG2Y=0

# Test for arrays
test_arr=FAIL
Array=( FAIL PASS )
test_arr=${Array[1]}
if [ "$test_arr" = xFAIL ]; then
    echo "This script requires the bash shell as it uses bash arrays."
    exit -1
fi

# Params for time list production
TFIRST=0.4
TINC=0.6

function tlist {
    echo "scale=3;
          var1 = ${TFIRST} + ${TINC} * ${1};
          if(var1<1) print 0; var1 " | bc
}

declare -a TLIST
for TLI in `seq 0 15`; do
    TLIST[$TLI]=$(tlist ${TLI})
done

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
     "widthThetaX":6,"widthThetaY":2,"luminance":0.300000,
     "timeOn":0,"timeOff":${TLIST[0]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[0]},"timeOff":${TLIST[1]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[1]},"timeOff":${TLIST[2]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[2]},"timeOff":${TLIST[3]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[3]},"timeOff":${TLIST[4]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[4]},"timeOff":${TLIST[5]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[5]},"timeOff":${TLIST[6]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[6]},"timeOff":${TLIST[7]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[7]},"timeOff":${TLIST[8]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[8]},"timeOff":${TLIST[9]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[9]},"timeOff":${TLIST[10]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[10]},"timeOff":${TLIST[11]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[11]},"timeOff":${TLIST[12]}},

     {"shape":"cross","thetaX":${TARGX},"thetaY":${TARGY},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[12]},"timeOff":${TLIST[13]}},

     {"shape":"cross","thetaX":${TARG2X},"thetaY":${TARG2Y},
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[13]},"timeOff":${TLIST[14]}},

    {"shape":"cross","thetaX":0,"thetaY":0,
     "widthThetaX":6,"widthThetaY":2,"luminance":0.3,
     "timeOn":${TLIST[15]},"timeOff":100}
 ]
}
EOF

popd

pushd ${S2B_DIR}

for i in 1 2 3; do
    ./convert_script_s2b  -m ${OMMPATH} -e10 -o temp/${OMMODEL}

    # Now extract the movement data and save it off, then re-run several times.
    FNAME=${i}_TX${TARGX}TY${TARGY}T2X${TARG2X}T2Y${TARG2Y}

    #
    # Eye rotations
    #
    cp ${S2B_DIR}/temp/${OMMODEL}/run/saccsim_side.log ${STARTDIR}/results/${FNAME}_saccsim_side.log

    #
    # LLBN
    #
    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_down_a_log.bin ${STARTDIR}/results/${FNAME}_LLBN_down_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_down_a_logrep.xml ${STARTDIR}/results/${FNAME}_LLBN_down_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_up_a_log.bin ${STARTDIR}/results/${FNAME}_LLBN_up_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_up_a_logrep.xml ${STARTDIR}/results/${FNAME}_LLBN_up_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_left_a_log.bin ${STARTDIR}/results/${FNAME}_LLBN_left_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_left_a_logrep.xml ${STARTDIR}/results/${FNAME}_LLBN_left_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_right_a_log.bin ${STARTDIR}/results/${FNAME}_LLBN_right_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/LLBN_right_a_logrep.xml ${STARTDIR}/results/${FNAME}_LLBN_right_a_logrep.xml

    #
    # MN
    #
    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_right_a_log.bin ${STARTDIR}/results/${FNAME}_MN_right_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_right_a_logrep.xml ${STARTDIR}/results/${FNAME}_MN_right_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_left_a_log.bin ${STARTDIR}/results/${FNAME}_MN_left_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_left_a_logrep.xml ${STARTDIR}/results/${FNAME}_MN_left_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_up_a_log.bin ${STARTDIR}/results/${FNAME}_MN_up_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_up_a_logrep.xml ${STARTDIR}/results/${FNAME}_MN_up_a_logrep.xml

    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_down_a_log.bin ${STARTDIR}/results/${FNAME}_MN_down_a_log.bin
    cp ${S2B_DIR}/temp/${OMMODEL}/log/MN_down_a_logrep.xml ${STARTDIR}/results/${FNAME}_MN_down_a_logrep.xml


done
