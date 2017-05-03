#$ -l h_rt=120:00:00   -l mem=16G
#$ -P insigneo-notremor
#$ -q insigneo-notremor.q
./convertLogs
./movieFast.sh
