#!/bin/sh
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

if [ -z "$2" ]; then
	echo "ThetaX/ThetaY please"
	exit -1
fi

THETAX="$1"
THETAY="$2"

INSIGNEO=1
CLEANUP=1
NUM_RUNS=8

# Things to check before running:
# Is the luminance file correctly written out?
# Are there any extra params to go in the convert_script_s2b call in run_simulation_multi.m?
# Is the correct explicitDataBinaryFileN.bin being written into?

pushd /home/pc1ssj/abrg_local/Oculomotor/batch_scripts

/home/pc1ssj/usr/bin/octave -q --eval "octave_run_test"
oct_run_rtn=$?
if [ $oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi

# Get startweight from the weight maps. First load the maps, then
# consider which quadrant we're in, then select the weight from the
# relevant maps.
## STARTWEIGHTS=`/home/pc1ssj/usr/bin/octave -q --eval "startweights(${THETAX},${THETAY},'/home/pc1ssj/abrg_local/Oculomotor/lab_book/201509_Combined_RotZ_Training')"`

/home/pc1ssj/usr/bin/octave -q --eval \
 "rotations_weight_prover([${THETAX},${THETAY},0],${NUM_RUNS},${INSIGNEO},${CLEANUP})"
popd

exit 0
