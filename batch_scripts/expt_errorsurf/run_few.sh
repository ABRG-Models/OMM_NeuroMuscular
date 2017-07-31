#!/bin/bash

# Run through a set of targets at different locations, qsubbing
# NUM_RUNS of the model for each target. Results (average saccade
# size, saccade size SD) are stored in octave data files. Load these
# and plot using plot_errorsurf.m
#
# This is a bit like one iteration of the old weight training
# algorithm that I implemented.

# Fixed parameters for this run:
LUMVAL=0.3
DOPAMINE=0.7
GAP_MS=0
NUM_RUNS=6

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='TModel3'
mkdir -p results/${OMMODEL}

PARENT_LIMIT=28

# The list of angles to re-do. RX-4RY8 is the format, with spaces separating.
LIST="RX-11RY-3 RX-12RY7 RX-4RY-11 RX-8RY-12 RX-8RY-5"

for tag in $LIST; do

    # while num jobs of this type > 10, wait...
    NUM_PARENTS=`qstat -u co1ssj | grep ESURF | wc -l`
    while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
        sleep 15
        NUM_PARENTS=`qstat -u co1ssj | grep ESURF | wc -l`
    done

    i=`echo $tag | awk -F 'R' '{print $2}' | tr --delete "X"`
    j=`echo $tag | awk -F 'R' '{print $3}' | tr --delete "Y"`

    # Now we can add another one...
    if [ ${P_STR} = 'iceberg' ]; then
        # 1) write out a script we can qsub for the luminance:
        cat > scriptx${i}x${j}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
    elif [ ${P_STR} = 'ace2' ]; then
        cat > scriptx${i}x${j}.sh <<EOF
#!/bin/bash

EOF
    fi

    cat >> scriptx${i}x${j}.sh <<EOF
env
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_targetpos_horz
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

mkdir -p ./results/${OMMODEL}
octave -q --eval "perform_saccade('./results/${OMMODEL}',${i},${j},${NUM_RUNS},${GAP_MS},${LUMVAL},${DOPAMINE})"
exit 0
EOF

    # 2) and then qsub it:
    PROJECT_TAG=''
    if [ ${P_STR} = 'iceberg' ]; then
        PROJECT_TAG='-P insigneo-notremor'
    fi
    # On iceberg, the environment, and hence OMMODEL is available on
    # qsubbed jobs, on ace2 it isn't, hence use of -v option here.
    qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N ESURFx${i}y${j} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_errorsurf -o results/ESURFx${i}y${j}.out -j y ./scriptx${i}x${j}.sh

    # 3) Clean up the script
    rm -f ./scriptx${i}x${j}.sh

done
