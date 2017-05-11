#!/bin/bash

# Run through a set of targets a different locations, qsubbing
# NUM_RUNS of the model for each target. Results (average saccade
# size, saccade size SD) are stored in octave data files. Load these
# and plot using plot_sacc_vs_t.m

THETAXSTART=-7
THETAXINC=-1
THETAXEND=-14

THETAY=0
NUM_RUNS=6

LUMVAL=1.8

mkdir -p results

for targxval in `seq ${THETAXSTART} ${THETAXINC} ${THETAXEND}`; do

    # 1) write out a script we can qsub for the luminance:
    cat > script${targxval}.sh <<EOF
#!/bin/bash
#$ -l mem=4G
#$ -l rmem=4G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

pushd /home/co1ssj/OMM_NeuroMuscular/batch_scripts
/home/co1ssj/usr/bin/octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

/home/co1ssj/usr/bin/octave -q --eval "sacc_vs_targetpos(${targxval},${THETAY},${NUM_RUNS},${LUMVAL})"
exit 0
EOF

    # 2) and then qsub it:
    qsub -P insigneo-notremor -N SVTP${targxval} -o results/SVTP${targxval}.out -j y ./script${targxval}.sh

    # 3) Clean up the script
    rm -f ./script${targxval}.sh

done
