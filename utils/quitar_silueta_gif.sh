#!/bin/bash

#echo "$#: $0 $1 $2 $3"

if [ -z "$2" ]; then OUTPUT="output_silueta.gif"; else OUTPUT="$2"; fi
if [ -z "$3" ]; then MSKFILE="msk.png"; else MSKFILE="$3"; fi

[ -f $MSKFILE ] || exit 3;

echo "OUTPUT=$OUTPUT    MSKFILE=$MSKFILE"

FRAMES="/tmp/frames"
OUTPUTFRAMES="$FRAMES/output"
[ -d $FRAMES ] && rm -r $FRAMES
mkdir -p $FRAMES $OUTPUTFRAMES

convert $1 -coalesce $FRAMES/frame_%03d.png

for img in $FRAMES/*.png; do
	composite -compose Dst_Out $MSKFILE "$img" "$OUTPUTFRAMES/$(basename "$img")"
done
convert -dispose background -delay 10 -loop 0 $OUTPUTFRAMES/frame_*.png $OUTPUT

