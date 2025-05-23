#/bin/bash

## Analizar opciones de línea de comandos
#OPTS=$(getopt -o c:h --long color:,help -n 'make_gif.sh' -- "$@")
#OPTS=$(getopt -o r:h --long fps,help -n $0 -- "$@")
OPTSARG="s:r:h --long search:fps:,help"
OPTS=$(getopt -o $OPTSARG -n $0 -- "$@")

if [ $? -ne 0 ]; then
  echo "Error al analizar opciones" >&2
  exit 1
fi

## Restablecer los parámetros posicionales a las opciones analizadas
eval set -- "$OPTS"

## Inicializar variables
#COLOR="0xB2D445"
#FPS="25"
STRSED="[^# \t][^ \t]*"

## Procesar las opciones
while true; do
	case "$1" in
	-h | --help)
		echo "AYUDA: $0 $OPTSARG"
		shift ;;
	-s | --search)
		STRSED="$2"
		shift 2 ;;
	-r | --fps)
		FPS="$2"
		shift 2 ;;
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

echo "FILE = $FILE, PATH = $PTH, FULLNAME = $FULLNAME , NAME = $NAME "

[ -f $FILE ] || { echo "Fichero $FILE no existe" ; exit 1; }

[ -f $PTH/$NAME.cut ] || { echo "Fichero $PTH/$NAME.cut no existe" ; exit 1; }

count=0;

while IFS= read -r line
do
	set -- $line
	if [ $# -lt 6 ]; then continue; fi
	echo "READ OBJ (%$#) $*: $1 $2 $3 $4 $5 $6"
	echo "FFMPEG $FILE a $PTH/$1 CROP: $5 desde $2 hasta $3 con $6 fps"
	PARAM="-y -nostdin -avoid_negative_ts make_zero -ss $2 -to $3 -i $FILE"

	if [ "$6" == "false" ]; then
		echo "NO HAY TRANSFORMACIÓN DE FPS......."
	else
		echo "HAY TRANSFORMACIÓN FPS......."
		PARAM+=" -r $6"
	fi

	echo "PARAM=$PARAM"

	ffmpeg $PARAM -vf "crop=$5" "$PTH/$1.mp4" 2>&1 > /dev/null
	
	if [ "$4" != "false" ]; then
		[ -d /tmp/$1 ] && rm -r /tmp/$1
		mkdir /tmp/$1

#		echo ">>>>> FFMPEG para hacer transparencias de fotogramas en /tmp/$1"
		ffmpeg -nostdin -i "$PTH/$1.mp4" -vf "colorkey=$4:0.1:0.0" -vsync 0 /tmp/$1/$1_%03d.png
#		echo ">>>>> CONVERT para reconstruir el gif animado en $PTH/$1-SR,gif"
		convert -dispose background -delay 10 -loop 0 /tmp/$1/$1_*.png $PTH/$1-SR.gif
	fi

done < <(sed -ne "/${SEDFILTER}/p" ${PTH}/${NAME}.cut)
