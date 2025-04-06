#!/bin/bash

# Comienza el archivo JS
echo "var imgSize = {" 

# Procesa archivos .jpg y .png
for f in *.jpg *.png; do
  # Verifica que el archivo exista para evitar errores si no hay coincidencias
  [ -e "$f" ] || continue
  w=$(identify -format "%w" "$f")
  h=$(identify -format "%h" "$f")
  echo "  \"$f\": { width: $w, height: $h }," 
done

# Cierra el objeto JS
echo "};"

