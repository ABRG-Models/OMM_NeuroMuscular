#!/bin/bash

set -m

# As framewidth increases, memory requirements on the server go
# up. The default for qrsh is enough for up to 200. 300 makes for nice big movies.
FRAMEWIDTH="150"

# How fast to make the movie go.
FRAMERATE=25

# MODIFY this to suit your environment.
LOGDIR='/fastdata/pc1ssj/oculomotor/log/'

POPULATIONS=('Retina_1' 'Retina_2' 'FEF' 'SC_deep' 'GPe' 'SC_sup' 'SNr' 'STN' 'Str_D1' 'Thalamus')
#             0          1          2     3         4     5        6      7    8        9

# The image type to use for the intermediate frames.
# jpg works fine. For png - images are created by imageMagick, but
# avconv doesn't convert 'em. pbm: in the convert call, the output
# file isn't expanded out into many individual files - all the frames
# are in the single file. (+adjoin fixes that but output is poor
# quality). bmp works about as well a jpg.
IMTYPE="jpg"

# BMAX is number of batches to run the parallel imagemagick commands in.
BMAX=60

# Do the split in a multi processor friendly way
for i in `seq 0 9`; do
    mkdir -p "$LOGDIR${POPULATIONS[$i]}"
    split -a 3 -b 5000 "$LOGDIR${POPULATIONS[$i]}"_out_uint16.bin  "$LOGDIR${POPULATIONS[$i]}"/frame_ &
done
while fg; do true; done

# Make sure the colour gradient exists
convert -size 10x50 gradient:gold-firebrick "$LOGDIR"gradient_burnished.jpg

# Have to do this sort of thing to do colour lookup on a series of
# images because clut applies to a series of inputs on the command
# line.
doParallelConvert() {
    declare -a montagelist=(${!1})

    local items item currentBatch=0
    for item in ${montagelist[@]}; do
        items[$currentBatch]="${items[$currentBatch]} $item"
        shift
        let currentBatch=$(( (currentBatch+1)%BMAX ))
    done

    FRCOUNT=1
    for (( currentBatch=0; currentBatch<BMAX; currentBatch++ ))
    do
        echo "Current convert batch: $currentBatch"
        for frame in ${items[$currentBatch]}; do
            #echo "Frame: $frame frame count: $FRCOUNT"
            #echo "convert -depth 16 -size 50x50 gray:\"$LOGDIR${POPULATIONS[$i]}\"/$frame \"$LOGDIR\"gradient_burnished.jpg -clut -resize $FRAMEWIDTHx$FRAMEWIDTH +adjoin \"$LOGDIR${POPULATIONS[$i]}\"/frame-$FRCOUNT.jpg &"
            convert -depth 16 -size 50x50 gray:"$LOGDIR"$frame \
                "$LOGDIR"gradient_burnished.jpg -clut -resize $FRAMEWIDTHx$FRAMEWIDTH \
                +adjoin "$LOGDIR"frame-$FRCOUNT.jpg &
            FRCOUNT=$((FRCOUNT+1))
        done
        while fg; do true; done
    done
    wait
}

#for i in `seq 0 9`; do
    # Convert line (or mogrify) with resize FIXME: Add quality for jpeg loss here.
#    echo "Imagemagick for ${POPULATIONS[$i]}"
#    convert -depth 16 -size 50x50 gray:"$LOGDIR${POPULATIONS[$i]}"/frame_* "$LOGDIR"gradient_burnished.jpg -clut -resize $FRAMEWIDTHx$FRAMEWIDTH +adjoin "$LOGDIR${POPULATIONS[$i]}"/frame%03d.jpg &
#done
#while fg; do true; done

for i in `seq 0 9`; do
    echo "${POPULATIONS[$i]} "
    declare -a CONVERT_LIST
    j=0
    for i in ${POPULATIONS[$i]}/frame_*; do
        CONVERT_LIST[$j]=$i
        j=$((j+1))
    done
    doParallelConvert CONVERT_LIST[@]
done

exit

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
        echo "Current montage batch: $currentBatch"
        for frame in ${items[$currentBatch]}; do
            montage -background '#336699' -geometry +2+2 -tile 4x \
                -label ${POPULATIONS[1]} ../${POPULATIONS[1]}/$frame \
                -label ${POPULATIONS[2]} ../${POPULATIONS[2]}/$frame  \
                -label ${POPULATIONS[9]} ../${POPULATIONS[9]}/$frame  \
                -label ${POPULATIONS[8]} ../${POPULATIONS[8]}/$frame  \
                -label ${POPULATIONS[7]} ../${POPULATIONS[7]}/$frame  \
                -label ${POPULATIONS[6]} ../${POPULATIONS[6]}/$frame  \
                -label ${POPULATIONS[5]} ../${POPULATIONS[5]}/$frame  \
                -label ${POPULATIONS[3]} ../${POPULATIONS[3]}/$frame  \
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
