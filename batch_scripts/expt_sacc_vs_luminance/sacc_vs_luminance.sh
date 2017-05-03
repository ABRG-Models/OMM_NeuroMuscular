#!/bin/bash

# Run through a set of luminances, qsubbing NUM_RUNS of the model for
# each luminance. Results (average saccade size, saccade size SD) are
# stored in octave data files. Load these and plot using
# plot_sacc_vs_l.m

XSTART=0.2
XINC=0.2
XEND=1.6

THETAX=0
THETAY=7
NUM_RUNS=6

for lval in `seq ${XSTART} ${XINC} ${XEND}`; do

    # 1) write out a script we can qsub for the luminance:
    cat > script${lval}.sh <<EOF
#!/bin/bash
#$ -l mem=2G
#$ -l rmem=2G
#$ -l h_rt=4:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

pushd /home/pc1ssj/abrg_local/Oculomotor/batch_scripts
/home/pc1ssj/usr/bin/octave -q --eval "octave_run_test"
oct_run_rtn=\$?
if [ \$oct_run_rtn -gt "0" ]; then
    echo "Failed to run Octave on this host, exiting."
    popd
    exit 1
fi
popd

/home/pc1ssj/usr/bin/octave -q --eval "sacc_vs_luminance(${THETAX},${THETAY},${NUM_RUNS},${lval})"
exit 0
EOF

    # 2) and then qsub it:
    qsub -P insigneo-notremor -N SVL${lval} -o SVL${lval}.out -j y ./script${lval}.sh

    # 3) Clean up the script
    rm -f ./script${lval}.sh

done
