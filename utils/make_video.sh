#!/bin/bash

## Analizar opciones de línea de comandos
#OPTS=$(getopt -o hc --long help,color -n'make_gif.sh' -- "$@")
OPTSARG="r:s:d:e:c:fqh --long fps:search:delay:,ext:,color:,forcei,quit,help"
OPTS=$(getopt -o $OPTSARG -n $0 -- "$@")

if [ $? -ne 0 ]; then
  echo "Error al analizar opciones" >&2
  exit 1
fi

## Restablecer los parámetros posicionales a las opciones analizadas
eval set -- "$OPTS"

## Inicializar variables
#COLOR="0xB2D445"
COLOR="false"
EXT="gif"
FORCE=false
QUIT=false
DELAY="10"
STRSED="[^# \t][^ \t]*"
FPS=false

## Procesar las opciones
while true; do
	case "$1" in
	-h | --help)
		echo "AYUDA: $0 $OPTSARG"
		exit 0 ;;
	-c | --color)
		COLOR="$2"
		shift 2 ;;
	-e | --ext)
		EXT="$2"
		shift 2 ;;
	-f | --force)
		FORCE=true
		shift ;;
	-d | --delay)
		DELAY="$2"
		shift 2 ;;
	-r | --fps)
		FPS="$2"
		shift 2 ;;
	-s | --search)
		STRSED="$2"
		shift 2 ;;
	-q | --quit)
		QUIT=true
		shift ;;
	--)
		shift
		break ;;
	*)
		echo "ERROR: $0 $OPTSARG"
		exit 1 ;;
	esac
done

FILE=$1
PTH=`dirname "$FILE"`
FULLNAME="${FILE##*/}"
NAME="${FULLNAME%.*}"
SEDFILTER="^${STRSED}[ \t]"

echo "SEDFILTER=$SEDFILTER"

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
#	for img in `ls -rt /tmp/${NAME}/${NAME}_*.png | head -n $MAXFRAME | tail -n $(($MAXFRAME-$3+1))`
#	RANGE="{$3..$MAXFRAME}"
	RANGE=`awk "BEGIN {for(i=$3;i<=${MAXFRAME};i++) printf \"%03d \",i; print}"`

	echo "RANGE=$RANGE"
	for numimg in `eval echo $RANGE`
	do
		img="/tmp/${NAME}/${NAME}_${numimg}.png"
		baseimg=$(basename $img)
#		numimg=`echo $baseimg|sed -e "s/^${NAME}_\([0-9]*\)\.png/\1/"`

		echo "CONVERTIR $img a ${baseimg} numimg=$numimg"
		echo convert "$img" -crop $2 +repage "/tmp/${NAME}/$1/${baseimg%.*}_$1.png"
		convert "$img" -crop $2 +repage "/tmp/${NAME}/$1/${NAME}_$1_${numimg}.png" > /dev/null
	done
	

}


if [ ! -d /tmp/${NAME} ]; then
	mkdir /tmp/${NAME}
	OPTS=""
	if [ "${COLOR}" != "false" ]; then
		OPTS+=" -vf colorkey=${COLOR}:0.1:0.0" 
	fi
	if [ "${FPS}" != "false" ]; then
		OPTS+=" -r ${FPS}" 
	fi
	OPTS+=" -vsync 0"
	echo "OPTS=$OPTS"
	ffmpeg -i ${FILE} ${OPTS} /tmp/${NAME}/${NAME}_%03d.png > /dev/null
	echo "Construido los fotogramas en /tmp/$NAME"
fi

if [ $QUIT == true ]; then echo "SALIR DEL PROGRAMA";exit 2;fi

[ -f $PTH/conf/$NAME.conf ] || { echo "Fichero $PTH/conf/$NAME.conf no existe" ; exit 1; }

[ -d $PTH/$EXT ] || mkdir $PTH/$EXT
while IFS= read -r line
do
	set -- $line 
	if [ $# -lt 4 ]; then continue; fi
#	echo "READ OBJ ($#) $*: $1 $2 $3 $4"
	createObj $line
	echo "CREAR $EXT FINAL en $PTH/$EXT/${NAME}_$1-SR.$EXT con delay=$DELAY"
	convert -dispose background -delay $DELAY -loop 0 /tmp/${NAME}/$1/${NAME}_$1_*.png $PTH/$EXT/${NAME}_$1-SR.$EXT > /dev/null

done < <(sed -ne "/${SEDFILTER}/p" ${PTH}/conf/${NAME}.conf)

