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

XSTART=-17 # full run
XEND=0
YSTART=-17
YEND=17
#XSTART=-14 # for testing
#XEND=-12
#YSTART=-12
#YEND=12
PARENT_LIMIT=28
MIN_RAD=6 # Can be down to 6; depends on target size and fovealmask in the model
MAX_RAD=18

for i in `seq ${XSTART} ${XEND}`; do

    for j in `seq ${YSTART} ${YEND}`; do

        # Avoid the central region. Calculate distance to centre
        d_lt=`echo "scale=10;sqrt(${i}*${i}+${j}*${j})<$MIN_RAD"|bc`
        d_gt=`echo "scale=10;sqrt(${i}*${i}+${j}*${j})>$MAX_RAD"|bc`
        if [ $d_lt -gt 0 ]; then
            echo "Omit Theta X = $i, Theta Y = $j (within $MIN_RAD deg)"
            continue
        fi
        if [ $d_gt -gt 0 ]; then
            echo "Omit Theta X = $i, Theta Y = $j (outside $MAX_RAD deg)"
            continue
        fi
	echo "Keep Theta X = $i, Theta Y = $j"

        # while num jobs of this type > 10, wait...
        NUM_PARENTS=`qstat -u co1ssj | grep ESURF | wc -l`
        while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
            sleep 15
            NUM_PARENTS=`qstat -u co1ssj | grep ESURF | wc -l`
        done

        # Now we can add another one...
        #qsub -P insigneo-notremor -N RX${i}RY${j} \
        #    -o /fastdata/pc1ssj/runwfRX${i}RY${j}.out -j y \
        #    ./run_weight_finding_3d.sh "$i" "$j" 0.8
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
done
