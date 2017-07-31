#!/bin/bash

# Run through a set of experiments with different gap/overlaps for given LUMVAL and DOPVAL
# qsubbing NUM_RUNS of the model for each gap. Results (average
# saccade size, saccade size SD, latency, latency SD) are stored in
# octave data files. Load these and plot using plot_sacc_vs_g.m

# Fixed parameters
LUMVAL=1
GAP_MS=0
THETAX=-10
THETAY=0

DOPSTART=0.2
DOPINC=0.1
DOPEND=1.0

NUM_RUNS=12

# Ensure results dir exists
mkdir -p results

# Determine platform
P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='TModel4'

for dopval in `seq $DOPSTART $DOPINC $DOPEND`; do

    if [ ${P_STR} = 'iceberg' ]; then
        # 1) write out a script we can qsub for the luminance:
        cat > script${dopval}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
    elif [ ${P_STR} = 'ace2' ]; then
        cat > script${dopval}.sh <<EOF
#!/bin/bash

EOF
    fi

    cat >> script${dopval}.sh <<EOF
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_latency_vs_dopamine
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

mkdir -p results/${OMMODEL}
octave -q --eval "perform_saccade('results/${OMMODEL}',${THETAX},${THETAY},${NUM_RUNS},${GAP_MS},${LUMVAL},${dopval})"
exit 0
EOF

    # 2) and then qsub it:
    PROJECT_TAG=''
    if [ ${P_STR} = 'iceberg' ]; then
        PROJECT_TAG='-P insigneo-notremor'
    fi
    qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N SVDOP${dopval} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_dopamine -o results/SVDOP${dopval}.out -j y ./script${dopval}.sh

    # 3) Clean up the script
    rm -f ./script${dopval}.sh

done
