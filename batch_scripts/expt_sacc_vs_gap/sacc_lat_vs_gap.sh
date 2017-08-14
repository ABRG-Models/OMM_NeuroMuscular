#!/bin/bash

# Run through a set of experiments with different gap/overlaps,
# qsubbing NUM_RUNS of the model for each gap. Results (average
# saccade size, saccade size SD, latency, latency SD) are stored in
# octave data files. Load these and plot using plot_sacc_vs_g.m

# Very fixed params
THETAX=0
THETAY=-10

# Vary these per-run.
# LUMVAL=2
# DOPAMINE=0.7
# FIXLUM=0.15

EXPTNUM=5 # 5 normal model, 6 reflexive model, 7 express model

NUM_RUNS=6
PARENT_LIMIT=29

mkdir -p results

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='TModel4'

#for DOPAMINE in 0.7; do
#    for FIXLUM in 0.15; do
#        for LUMVAL in 2; do

for DOPAMINE in 0.7 0.4 0.1; do
    for FIXLUM in 0.1 0.15 0.2; do
        for LUMVAL in 2 1 0.6 0.3; do

            for gapval in `seq -250 50 350`; do

                echo "Queuing for: Gap: $gapval ms for DA=$DOPAMINE, FL=$FIXLUM, TL=$LUMVAL..."

                # while num jobs of this type > 10, wait...
                NUM_PARENTS=`qstat -u co1ssj | grep SVG | wc -l`
                while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
                    sleep 15
                    NUM_PARENTS=`qstat -u co1ssj | grep SVG | wc -l`
                done

                if [ ${P_STR} = 'iceberg' ]; then
                    # 1) write out a script we can qsub for the luminance:
                    cat > script${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
                elif [ ${P_STR} = 'ace2' ]; then
                    cat > script${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.sh <<EOF
#!/bin/bash

EOF
                fi

                cat >> script${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.sh <<EOF
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_latency_vs_gap
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd
mkdir -p results/${OMMODEL}
octave -q --eval "perform_saccade('results/${OMMODEL}',${THETAX},${THETAY},${NUM_RUNS},${gapval},${LUMVAL},${DOPAMINE},${FIXLUM},${EXPTNUM})"
exit 0
EOF

                # 2) and then qsub it:
                PROJECT_TAG=''
                if [ ${P_STR} = 'iceberg' ]; then
                    PROJECT_TAG='-P insigneo-notremor'
                fi
                qsub ${PROJECT_TAG} -v OMMODEL=${OMMODEL} -N SVG${gapval}${LUMVAL}${FIXLUM}${DOPAMINE} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_gap -o results/SVG${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.out -j y ./script${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.sh

                # 3) Clean up the script
                rm -f ./script${gapval}${LUMVAL}${FIXLUM}${DOPAMINE}.sh

            done
        done
    done
done
