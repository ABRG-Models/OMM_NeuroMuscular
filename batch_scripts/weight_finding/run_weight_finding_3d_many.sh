#!/bin/sh
#$ -l mem=1G
#$ -l rmem=1G
#$ -l h_rt=127:59:00
#$ -m ae
#$ -M seb.james@sheffield.ac.uk

# Things to check before running:
# Is the luminance file correctly written out?
# Are there any extra params to go in the convert_script_s2b call in run_simulation_multi.m?
# Is the correct explicitDataBinaryFileN.bin being written into?

# Simultaneously run the weight finding algorithm for all the eccentricities of interest:

XSTART=-22
XEND=22
YSTART=-22
YEND=22

PARENT_LIMIT=28

MIN_RAD=6 # Can be down to 6
MAX_RAD=22.5

echo "$0 - Theta X range: ${XSTART} to ${XEND}; Theta Y range:  ${YSTART} to ${YEND}" >> ~/fast/allweights.log
echo "explicitDataBinaryFileN.bin: L:50 R:52 U:53 D:54 Z+:58 Z-:57" >> ~/fast/allweights.log
echo -n "Start date: "
date >> ~/fast/allweights.log
echo "Cols: weights file, axis, target angles (x/y/z), peakposn1, peakposn2, bestweight, meanpeakposn1, meanpeakposn2, eyeposAvg(SD) (x/y/z)." >> ~/fast/allweights.log

# I'm going to have to add jobs and monitor them and keep only about
# PARENT_LIMIT of these jobs running at once, otherwise I'll run out
# of available hosts to run the "worker" jobs (those which actually
# run the simulation).
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
        NUM_PARENTS=`qstat -u pc1ssj | grep RX | wc -l`
        while [ $NUM_PARENTS -gt $PARENT_LIMIT ]; do
            sleep 15
            NUM_PARENTS=`qstat -u pc1ssj | grep RX | wc -l`
        done

        # Now we can add another one...
        qsub -P insigneo-notremor -N RX${i}RY${j} \
            -o /fastdata/pc1ssj/runwfRX${i}RY${j}.out -j y \
            ./run_weight_finding_3d.sh "$i" "$j" 0.8

    done
done
