#!/bin/sh
#$ -l mem=1G
#$ -l rmem=1G
#$ -l h_rt=64:59:00

# This script cleans up /fastdata/pc1ssj following weight training or
# other model runs. It can take a long time and should be qsubbed.

pushd /fastdata/pc1ssj
rm rwf3dmany*
rm r[0-9]*_run_sim.sh
rm logRX*
mv allweights.log allweights.log.1
find -maxdepth 1 -path './oculomotorRX*' -exec rm -rf {} \;
popd
