#!/bin/bash

IMGDIR=${1:-"photos"}

# Comienza el archivo JS
echo "var imgSize = {" 

# Procesa archivos .jpg y .png
for f in $IMGDIR/*.jpg $IMGDIR/*.png; do
  # Verifica que el archivo exista para evitar errores si no hay coincidencias
  [ -e "$f" ] || continue
  w=$(identify -format "%w" "$f")
  h=$(identify -format "%h" "$f")
  bf=$(basename "$f")
  echo "  \"$bf\": { width: $w, height: $h }," 
done

# Cierra el objeto JS
echo "};"

