#!/bin/bash

## Analizar opciones de línea de comandos
#OPTS=$(getopt -o hc --long help,color -n'make_gif.sh' -- "$@")
OPTS=$(getopt -o d:e:c:fh --long delay,ext:,color:,force,help -n $0 -- "$@")

if [ $? -ne 0 ]; then
  echo "Error al analizar opciones" >&2
  exit 1
fi

## Restablecer los parámetros posicionales a las opciones analizadas
eval set -- "$OPTS"

## Inicializar variables
COLOR="0xB2D445"
EXT="gif"
FORCE=false
HELP=false
DELAY="10"

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
    -e | --ext)
      EXT="$2"
      shift 2
      ;;
    -f | --force)
      FORCE=true
      shift 2
      ;;
    -d | --delay)
      DELAY="%2"
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

[ $FORCE == true ] && rm -r /tmp/$NAME

echo "FILE = $FILE, PATH = $PTH, FULLNAME = $FULLNAME , NAME = $NAME "

[ -f $FILE ] || { echo "Fichero $FILE no existe" ; exit 1; }

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
		convert "$img" -crop $2 +repage "/tmp/${NAME}/$1/${NAME}_$1_${numimg}.png" > /dev/null
	done
	

}


if [ ! -d /tmp/${NAME} ]; then
	mkdir /tmp/${NAME}

	echo ffmpeg -i ${FILE} -vf "colorkey=$COLOR:0.1:0.0, format=rgba" -vsync 0 /tmp/${NAME}/${NAME}_%03d.png

	echo "Directorio ${FILE}"

	if [ "${COLOR}" == "false" ]; then
		echo "NO SE HACE TRANSPARENCIA DE COLOR"
		ffmpeg -i ${FILE} -vsync 0 /tmp/${NAME}/${NAME}_%03d.png > /dev/null
	else
		echo "TRANSPARENCIA DE COLOR en: $COLOR"
		VFTXT="colorkey=${COLOR}:0.1:0.0" 
		ffmpeg -i ${FILE} -vf $VFTXT -vsync 0 /tmp/${NAME}/${NAME}_%03d.png > /dev/null
	fi
fi

[ -f $PTH/conf/$NAME.conf ] || { echo "Fichero $PTH/conf/$NAME.conf no existe" ; exit 1; }

[ -d $PTH/$EXT ] || mkdir $PTH/$EXT
while IFS= read -r line
do
	set -- $line
	echo "READ OBJ (%$#) $*: $1 $2 $3 $4"
#	if $# != 3; then continue; fi
	createObj $line
	convert -dispose background -delay $DELAY -loop 0 /tmp/${NAME}/$1/${NAME}_$1_*.png $PTH/$EXT/${NAME}_$1-SR.$EXT > /dev/null

done < ${PTH}/conf/${NAME}.conf

