#!/bin/bash

XLOC=150

# To use this script, define these environment variables:
# SPINEML_2_BRAHMS_DIR The locn of the SpineML_2_BRAHMS dir
# SACCSIM_DIR The location of your clone of the saccsim src repo
# ABRG_LOCAL_DIR  The location of your clone of the ABRG models git repo
# Here are Alex's
# export SPINEML_2_BRAHMS_DIR=$HOME/SpineML_2_BRAHMS
# export SACCSIM_DIR=$HOME/saccsim
# export ABRG_LOCAL_DIR=$HOME/abrg_local

# Test for the existence of these env. vars:
if [ "x$SPINEML_2_BRAHMS_DIR" = "x" ] || [ "x$SACCSIM_DIR" = "x" ] || [ "x$ABRG_LOCAL_DIR" = "x" ]
then
    echo "Please ensure that the following environment variables are defined:"
    echo "SPINEML_2_BRAHMS_DIR, SACCSIM_DIR, ABRG_LOCAL_DIR and OM_MODEL_RUNTIME"
    exit -1
fi

rm $SPINEML_2_BRAHMS_DIR/temp/*

if [ "x$DEG" = "x" ]; then
    echo "Please define DEG environment var with a sensible number."
    echo "For example: DEG=5 ./runAll.sh"
    exit -1
fi

export DEG
export XLOC=$((XLOC-DEG))

cd $ABRG_LOCAL_DIR/Oculomotor/matlab

xterm -e "octave worldDataMaker.m"&

sleep 5

cd $SPINEML_2_BRAHMS_DIR
OUTDIR=/fastdata/$USER/oculomotor
mkdir -p $OUTDIR
./convert_script_s2b -m $ABRG_LOCAL_DIR/Oculomotor -e 1 -o $OUTDIR

pwd
cp $OUTDIR/run/saccsim_side.log $ABRG_LOCAL_DIR/Oculomotor/matlab
cp $OUTDIR/log/SNr_out_log.bin  $ABRG_LOCAL_DIR/Oculomotor/matlab

sleep 1

cd $ABRG_LOCAL_DIR/Oculomotor/matlab

# save_output.oct makes use of OUTDIR
export OUTDIR
octave save_output.oct

echo "done"
