#!/bin/bash

# Run through a set of targets a different locations, qsubbing
# NUM_RUNS of the model for each target. Results (average saccade
# size, saccade size SD) are stored in octave data files. Load these
# and plot using plot_sacc_vs_t.m

# Fixed parameters
THETAX=0 # Integer values only
THETAY=-10
DOPAMINE=0.7
GAP_MS=0

NUM_RUNS=6

LUMVALSTART=0.6 # 0.5?
LUMVALEND=4.4 # 2.0?
LUMVALINC=0.2

# Use an env. variable to select which model to run.
export OMMODEL='Model3'

mkdir -p results

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

for lumval in `seq ${LUMVALSTART} ${LUMVALINC} ${LUMVALEND}`; do

    if [ ${P_STR} = 'iceberg' ]; then
        # 1) write out a script we can qsub for the luminance:
        cat > script${lumval}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
    elif [ ${P_STR} = 'ace2' ]; then
        cat > script${lumval}.sh <<EOF
#!/bin/bash

EOF
    fi

    cat >> script${lumval}.sh <<EOF
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_luminance
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

# Need to add path for sacc_vs_targetpos:
octave -q --eval "perform_saccade(${THETAX},${THETAY},${NUM_RUNS},${GAP_MS},${lumval},${DOPAMINE})"
exit 0
EOF

    # 2) and then qsub it:
    PROJECT_TAG=''
    if [ ${P_STR} = 'iceberg' ]; then
        PROJECT_TAG='-P insigneo-notremor'
    fi
    qsub ${PROJECT_TAG} -N SVL${lumval} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_luminance -o results/SVL${lumval}.out -j y ./script${lumval}.sh

    # 3) Clean up the script
    rm -f ./script${lumval}.sh

done
