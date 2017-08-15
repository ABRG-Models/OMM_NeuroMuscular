#!/bin/bash

set -m

# The output framewidth for each individual population.
# As framewidth increases, memory requirements on the server go
# up. The default for qrsh is enough for up to 200. 300 makes for nice big movies.
FRAMEWIDTH="200"

# How fast to make the movie go.
FRAMERATE=25

# MODIFY this to suit your environment.
LOGDIR='/fastdata/co1ssj/oculomotor/log/'

# Paths to ImageMagick tools
MONTAGE='/home/co1ssj/usr/bin/montage'
CONVERT='/home/co1ssj/usr/bin/convert'

POPULATIONS=('Retina_1' 'Retina_2' 'FEF' 'SC_deep' 'GPe' 'SC_sup' 'SNr' 'STN' 'Str_D1' 'Thalamus' 'FEF_add_noise' 'World')
#             0          1          2     3         4     5        6      7    8        9          10             11
# Length of the above array: ${#POPULATIONS[@]}
LAST_ELEMENT=$((${#POPULATIONS[@]}-1))

# The image type to use for the intermediate frames.
# jpg works fine. For png - images are created by imageMagick, but
# avconv doesn't convert 'em. pbm: in the convert call, the output
# file isn't expanded out into many individual files - all the frames
# are in the single file. (+adjoin fixes that but output is poor
# quality). bmp works about as well a jpg.
IMTYPE="jpg"

# Do the split in a multi processor friendly way
echo "split..."
for i in `seq 0 $LAST_ELEMENT`; do
    mkdir -p "$LOGDIR${POPULATIONS[$i]}"
    split -a 3 -b 2500 "$LOGDIR${POPULATIONS[$i]}"_out_uint8.bin  "$LOGDIR${POPULATIONS[$i]}"/frame_ &
done
while fg; do true; done

echo "convert..."
for i in `seq 0 $LAST_ELEMENT`; do
    # Convert line (or mogrify) with resize FIXME: Add quality for jpeg loss here.
    $CONVERT -depth 8 -size 50x50 gray:"$LOGDIR${POPULATIONS[$i]}"/frame_* -resize $FRAMEWIDTHx$FRAMEWIDTH +adjoin "$LOGDIR${POPULATIONS[$i]}"/frame.$IMTYPE &
done
while fg; do true; done

# BMAX is number of batches to run the montage commands in.
BMAX=60
doParallelMontage() {
    declare -a montagelist=(${!1})

    local items item currentBatch=0
    for item in ${montagelist[@]}; do
        items[$currentBatch]="${items[$currentBatch]} $item"
        shift
        let currentBatch=$(( (currentBatch+1)%BMAX ))
    done

    for (( currentBatch=0; currentBatch<BMAX; currentBatch++ ))
    do
        echo "Current batch: $currentBatch"
        for frame in ${items[$currentBatch]}; do
            $MONTAGE -background '#336699' -geometry +2+2 -tile 5x \
                -label ${POPULATIONS[1]} ../${POPULATIONS[1]}/$frame \
                -label ${POPULATIONS[2]} ../${POPULATIONS[2]}/$frame  \
                -label ${POPULATIONS[9]} ../${POPULATIONS[9]}/$frame  \
                -label ${POPULATIONS[8]} ../${POPULATIONS[8]}/$frame  \
                -label ${POPULATIONS[10]} ../${POPULATIONS[10]}/$frame  \
                -label ${POPULATIONS[7]} ../${POPULATIONS[7]}/$frame  \
                -label ${POPULATIONS[6]} ../${POPULATIONS[6]}/$frame  \
                -label ${POPULATIONS[5]} ../${POPULATIONS[5]}/$frame  \
                -label ${POPULATIONS[3]} ../${POPULATIONS[3]}/$frame  \
                -label ${POPULATIONS[11]} ../${POPULATIONS[11]}/$frame  \
                ../montage/$frame &
        done
        while fg; do true; done
    done
    wait
}

# Can do the montaging in a multiprocessor friendly way too, but it's
# harder because we don't have multiple populations to convert at the
# same time.
pushd $LOGDIR/Retina_1
mkdir -p ../montage
declare -a MONTAGE_LIST
j=0
for i in frame-*.$IMTYPE; do
    MONTAGE_LIST[$j]=$i
    j=$((j+1))
done
doParallelMontage MONTAGE_LIST[@]
popd

# make the movie. -y means overwrite the output file without asking
# without asking.
avconv -y -f image2 -r $FRAMERATE -i "$LOGDIR"/montage/frame-%d.$IMTYPE -qscale:v 2 "$LOGDIR"/montage.mpg
