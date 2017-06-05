#!/bin/bash

# Run through a set of experiments with different gap/overlaps,
# qsubbing NUM_RUNS of the model for each gap. Results (average
# saccade size, saccade size SD, latency, latency SD) are stored in
# octave data files. Load these and plot using plot_sacc_vs_g.m

# Fixed params
THETAX=0
THETAY=-8
LUMVAL=0.9
DOPAMINE=0.7

GAPSTART=-10 # Will need a longer expt to go more than 80 ms overlap
GAPINC=2
GAPEND=10

NUM_RUNS=12

mkdir -p results

P_STR='iceberg'
if [ -d /usr/local/abrg ]; then
    P_STR='ace2'
fi

# Use an env. variable to select which model to run.
export OMMODEL='Model3'

for gapval in `seq -80 20 80` `seq -10 2 10` 1 -1; do

    if [ ${P_STR} = 'iceberg' ]; then
        # 1) write out a script we can qsub for the luminance:
        cat > script${gapval}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

EOF
    elif [ ${P_STR} = 'ace2' ]; then
        cat > script${gapval}.sh <<EOF
#!/bin/bash

EOF
    fi

    cat >> script${gapval}.sh <<EOF
pushd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_latency_vs_gap
octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

octave -q --eval "perform_saccade(${THETAX},${THETAY},${NUM_RUNS},${gapval},${LUMVAL},${DOPAMINE})"
exit 0
EOF

    # 2) and then qsub it:
    PROJECT_TAG=''
    if [ ${P_STR} = 'iceberg' ]; then
        PROJECT_TAG='-P insigneo-notremor'
    fi
    qsub ${PROJECT_TAG} -N SVG${gapval} -wd ${HOME}/OMM_NeuroMuscular/batch_scripts/expt_sacc_vs_gap -o results/SVG${gapval}.out -j y ./script${gapval}.sh

    # 3) Clean up the script
    rm -f ./script${gapval}.sh

done
