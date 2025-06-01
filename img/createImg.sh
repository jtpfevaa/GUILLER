#!/bin/bash

# Carpeta de salida
OUTDIR="photos"
INDIR="ori"

mkdir -p "$OUTDIR"

# Parámetros del marco
MARGIN=15
HEADER=15
FONT_SIZE=20

# Fuente a usar (ajústala si no tienes DejaVu-Sans)
FONT="DejaVu-Sans"

# Procesar todos los .png y .jpg
for INPUT in $INDIR/*.png $INDIR/*.jpg $INDIR/*.webp; do
    [ -e "$INPUT" ] || continue  # Salta si no hay coincidencias

    # Nombre limpio
    BASENAME=$(basename "$INPUT")
    NAME_ONLY="${BASENAME%.*}"
#    OUTPUT="$OUTDIR/$BASENAME"
    OUTPUT="$OUTDIR/${NAME_ONLY}.png"

    # Obtener dimensiones
    WIDTH=$(identify -format "%w" "$INPUT")
    HEIGHT=$(identify -format "%h" "$INPUT")
    NEW_WIDTH=$((WIDTH + 2 * MARGIN))
    NEW_HEIGHT=$((HEIGHT + 2 * MARGIN + HEADER))

    # Crear imagen con marco y texto
    convert -size ${NEW_WIDTH}x${NEW_HEIGHT} xc:white \
      -font "$FONT" -pointsize $FONT_SIZE -fill black \
      -draw "text $MARGIN,$((HEADER + 10)) '$NAME_ONLY'" \
      "$INPUT" -geometry +$MARGIN+$((HEADER + MARGIN)) -composite \
      "$OUTPUT"

    echo "✔ Procesado: $INPUT → $OUTPUT"
done

echo "🎉 ¡Todas las imágenes han sido procesadas!"
