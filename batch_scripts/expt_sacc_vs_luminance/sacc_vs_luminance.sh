#!/bin/bash

# Run through a set of targets a different locations, qsubbing
# NUM_RUNS of the model for each target. Results (average saccade
# size, saccade size SD) are stored in octave data files. Load these
# and plot using plot_sacc_vs_l.m

# Fixed parameters
THETAX=0 # Integer values only
THETAY=-10
DOPAMINE=0.7

#GAP_MS=100 # -100 0 100
#FIXLUM=0.4

PARENT_LIMIT=29
NUM_RUNS=6

LUMVALSTART=0.25
LUMVALEND=3
LUMVALINC=0.25


EXPT=5 # 5 is like 0, but with 1 second duration.

# Use an env. variable to select which model to run.
export OMMODEL='TModel4'

mkdir -p results

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

for GAP_MS in -100 0 100; do
    for FIXLUM in 0.1 0.2 0.3; do
        for lumval in `seq ${LUMVALSTART} ${LUMVALINC} ${LUMVALEND}`; do

            # while num jobs of this type > 10, wait...
            NUM_PARENTS=`qstat -u co1ssj | grep SVL | wc -l`
            while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
                sleep 15
                NUM_PARENTS=`qstat -u co1ssj | grep SVL | wc -l`
            done


            if [ ${P_STR} = 'iceberg' ]; then
                # 1) write out a script we can qsub for the luminance:
                cat > script${lumval}${FIXLUM}${GAP_MS}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
            elif [ ${P_STR} = 'ace2' ]; then
                cat > script${lumval}${FIXLUM}${GAP_MS}.sh <<EOF
#!/bin/bash

EOF
            fi

            cat >> script${lumval}${FIXLUM}${GAP_MS}.sh <<EOF
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_luminance
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd
mkdir -p results/${OMMODEL}
# Need to add path for sacc_vs_targetpos:
octave -q --eval "perform_saccade('results/${OMMODEL}',${THETAX},${THETAY},${NUM_RUNS},${GAP_MS},${lumval},${DOPAMINE},${FIXLUM},${EXPT})"
exit 0
EOF

            # 2) and then qsub it:
            PROJECT_TAG=''
            if [ ${P_STR} = 'iceberg' ]; then
                PROJECT_TAG='-P insigneo-notremor'
            fi
            qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N SVL${lumval}${FIXLUM}${GAP_MS} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_luminance -o results/SVL${lumval}${FIXLUM}${GAP_MS}.out -j y ./script${lumval}${FIXLUM}${GAP_MS}.sh

            # 3) Clean up the script
            rm -f ./script${lumval}${FIXLUM}${GAP_MS}.sh

        done
    done
done
