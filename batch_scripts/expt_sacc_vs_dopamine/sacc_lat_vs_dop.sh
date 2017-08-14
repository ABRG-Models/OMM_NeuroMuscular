#!/bin/bash

# Run through a set of experiments with different gap/overlaps for given LUMVAL and DOPVAL
# qsubbing NUM_RUNS of the model for each gap. Results (average
# saccade size, saccade size SD, latency, latency SD) are stored in
# octave data files. Load these and plot using plot_sacc_vs_g.m

# Fixed parameters
#LUMVAL=1
#GAP_MS=80
THETAX=-10
THETAY=0

DOPSTART=0.2
DOPINC=0.1
DOPEND=1.0

PARENT_LIMIT=29
NUM_RUNS=6

EXPT=5

# Ensure results dir exists
mkdir -p results

# Determine platform
P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='TModel4'

for GAP_MS in -80 0 80; do
    for FIXLUM in 0.1 0.2 0.3; do
        for LUMVAL in 0.3 0.6; do
            for dopval in `seq $DOPSTART $DOPINC $DOPEND`; do

            # while num jobs of this type > 10, wait...
            NUM_PARENTS=`qstat -u co1ssj | grep SVD | wc -l`
            while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
                sleep 15
                NUM_PARENTS=`qstat -u co1ssj | grep SVD | wc -l`
            done


            if [ ${P_STR} = 'iceberg' ]; then
                # 1) write out a script we can qsub for the luminance:
                cat > script${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
            elif [ ${P_STR} = 'ace2' ]; then
                cat > script${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.sh <<EOF
#!/bin/bash

EOF
            fi

            cat >> script${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.sh <<EOF
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
octave -q --eval "perform_saccade('results/${OMMODEL}',${THETAX},${THETAY},${NUM_RUNS},${GAP_MS},${LUMVAL},${dopval},${FIXLUM},${EXPT})"
exit 0
EOF

            # 2) and then qsub it:
            PROJECT_TAG=''
            if [ ${P_STR} = 'iceberg' ]; then
                PROJECT_TAG='-P insigneo-notremor'
            fi
            qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N SVD${dopval}${LUMVAL}${FIXLUM}${GAP_MS} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_dopamine -o results/SVD${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.out -j y ./script${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.sh

            # 3) Clean up the script
            rm -f ./script${dopval}${LUMVAL}${FIXLUM}${GAP_MS}.sh

            done
        done
    done
done
