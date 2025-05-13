#!/bin/bash

#echo "$#: $0 $1 $2 $3"

if [ -z "$2" ]; then OUTPUT="output_transparent.gif"; else OUTPUT="$2"; fi
if [ -z "$3" ]; then COLOR="white"; else COLOR="#$3"; fi

echo "OUTPUT=$OUTPUT    COLOR=$COLOR"

FRAMES="/tmp/frames"
OUTPUTFRAMES="$FRAMES/output"
[ -d $FRAMES ] && rm -r $FRAMES
mkdir -p $FRAMES $OUTPUTFRAMES

convert $1 -coalesce $FRAMES/frame_%03d.png
for img in $FRAMES/*.png; do
    convert "$img" -fuzz 5% -transparent $COLOR "$OUTPUTFRAMES/$(basename "$img")"
done
convert -dispose background -delay 10 -loop 0 $OUTPUTFRAMES/frame_*.png $OUTPUT

