#!/bin/bash

# Run through a set of targets a different locations, qsubbing
# NUM_RUNS of the model for each target. Results (average saccade
# duration) are stored in octave data files. Load these
# and plot using plot_mainseq.m

# Note that this is mainseq for rotations about Y,
# i.e. horizontal movements.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0

# Negative theta X is a downward movement.
THETAXSTART=-7
THETAXINC=-1 # Stick to integers! Design of eyeframe/worldframe code requires this.
THETAXEND=-14

THETAY=0
NUM_RUNS=6

mkdir -p results

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='TModel4'

for targval in `seq ${THETAXSTART} ${THETAXINC} ${THETAXEND}`; do

    if [ ${P_STR} = 'iceberg' ]; then
        # 1) write out a script we can qsub for the luminance:
        cat > script${targval}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
    elif [ ${P_STR} = 'ace2' ]; then
c        cat > script${targval}.sh <<EOF
#!/bin/bash

EOF
    fi

    cat >> script${targval}.sh <<EOF
env
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_mainseq
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

mkdir -p ./results/${OMMODEL}_vert
octave -q --eval "perform_saccade('./results/${OMMODEL}_vert',${targval},${THETAY},${NUM_RUNS},${GAP_MS},${LUMVAL},${DOPAMINE})"
exit 0
EOF

    # 2) and then qsub it:
    PROJECT_TAG=''
    if [ ${P_STR} = 'iceberg' ]; then
        PROJECT_TAG='-P insigneo-notremor'
    fi
    # On iceberg, the environment, and hence OMMODEL is available on
    # qsubbed jobs, on ace2 it isn't, hence use of -v option here.
    qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N MSEQX${targval} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_mainseq -o results/MSEQX${targval}.out -j y ./script${targval}.sh

    # 3) Clean up the script
    rm -f ./script${targval}.sh

done
