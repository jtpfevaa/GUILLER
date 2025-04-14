#!/bin/bash

## Analizar opciones de línea de comandos
OPTS=$(getopt -o hc --long help,color -n'make_gif.sh' -- "$@")
OPTS=$(getopt -o c:h --long color:,help -n 'make_gif.sh' -- "$@")

if [ $? -ne 0 ]; then
  echo "Error al analizar opciones" >&2
  exit 1
fi

## Restablecer los parámetros posicionales a las opciones analizadas
eval set -- "$OPTS"

## Inicializar variables
COLOR="0xB2D445"
HELP=false

## Procesar las opciones
while true; do
  case "$1" in
    -h | --help)
      HELP=true
      shift
      ;;
    -c | --color)
      COLOR="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Error interno!"
      exit 1
      ;;
  esac
done

FILE=$1
PTH=`dirname "$FILE"`
FULLNAME="${FILE##*/}"
NAME="${FULLNAME%.*}"

echo "FILE = $FILE, PATH = $PTH, FULLNAME = $FULLNAME , NAME = $NAME "

[ -f $FILE ] || { echo "Fichero $FILE no existe" ; exit 1; }

[ -f $PTH/conf/$NAME.conf ] || { echo "Fichero $PTH/conf/$NAME.conf no existe" ; exit 1; }

createObj()
{
#	echo "RECIBIDO 1:$1 2:$2 3:$3 4:$4"
	MAXFRAME=`ls -rt /tmp/${NAME}/${NAME}_*.png | wc -l`
	if [ $MAXFRAME -gt $4 ]; then MAXFRAME=$4; fi 
#	echo "MAXFRAME=$MAXFRAME"
	[ -d /tmp/${NAME}/$1 ] && rm -r /tmp/${NAME}/$1
	mkdir /tmp/${NAME}/$1
	for img in `ls -rt /tmp/${NAME}/${NAME}_*.png | head -n $MAXFRAME | tail -n $(($MAXFRAME-$3+1))`
	do
		baseimg=$(basename $img)
		numimg=`echo $baseimg|sed -e "s/^${NAME}_\([0-9]*\)\.png/\1/"`

		echo "CONVERTIR $img a ${baseimg} numimg=$numimg"
		echo convert "$img" -crop $2 +repage "/tmp/${NAME}/$1/${baseimg%.*}_$1.png"
		convert "$img" -crop $2 +repage "/tmp/${NAME}/$1/${NAME}_$1_${numimg}.png"
	done
	

}


echo "TESTEAR: $NAME"

[ -d /tmp/${NAME} ] && rm -r /tmp/${NAME}

mkdir /tmp/${NAME}

echo ffmpeg -i ${FILE} -vf "colorkey=$COLOR:0.1:0.0, format=rgba" -vsync 0 /tmp/${NAME}/${NAME}_%03d.png

echo "Directorio ${FILE}"

VFTXT="colorkey=${COLOR}:0.1:0.0" 

echo "VFTXT= $VFTXT"

ffmpeg -i ${FILE} -vf $VFTXT -vsync 0 /tmp/${NAME}/${NAME}_%03d.png

[ -d $PTH/gifs ] || mkdir $PTH/gifs
while IFS= read -r line
do
	set -- $line
	echo "READ OBJ (%$#) $*: $1 $2 $3 $4"
#	if $# != 3; then continue; fi
	createObj $line
	convert -dispose background -delay 10 -loop 0 /tmp/${NAME}/$1/${NAME}_$1_*.png $PTH/gifs/${NAME}_$1-SR.gif

done < ${PTH}/conf/${NAME}.conf

