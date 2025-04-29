#!/bin/bash

## Analizar opciones de línea de comandos
#OPTS=$(getopt -o c:h --long color:,help -n 'make_gif.sh' -- "$@")
#OPTS=$(getopt -o r:h --long fps,help -n $0 -- "$@")
OPTSARG="o:d:p:I:w:h --long output:,so:,ini:,width:,help"
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
STEP=5
INI=100
WIDTH=300
DELAY=10
OUTPUT="false"

## Procesar las opciones
while true; do
	case "$1" in
	-h | --help)
		echo "AYUDA: $0 $OPTSARG"
		shift ;;
	-o | --output)
		OUTPUT="$2"
		shift 2 ;;
	-p | --paso)
		STEP="$2"
		shift 2 ;;
	-d | --delay)
		DELAY="$2"
		shift 2 ;;
	-I | --ini)
		INI="$2"
		shift 2 ;;
	-w | --width)
		WIDTH="$2"
		shift 2 ;;
	--)
		shift
		break ;;
	*)
		echo "ERROR: $0 $OPTSARG"
		exit 1 ;;
	esac
done

[ $# -lt 1 ] && { echo "Mal numero de parametros" ; exit 4;}


FILE=$1
PTH=`dirname "$FILE"`
FULLNAME="${FILE##*/}"
NAME="${FULLNAME%.*}"

[[ "$OUTPUT" == "false" ]] && OUTPUT="$PTH/${NAME}-MOV.gif"

echo "OUTPUT=$OUTPUT"

[ -f $FILE ] || { echo "Fichero $FILE no existe" ; exit 1; }

W=`identify -format "%w" $FILE`
H=`identify -format "%h" $FILE`

if [[ $WIDTH -gt $W ]]; then WIDTH=$W; fi
if [[ $((WIDTH+INI)) -gt $W ]]; then INI=$((W-WIDTH)); fi

echo "Imagen $FULLNAME de $W x $H se corta en WIDTH=$WIDTH desde INI=$INI con paso $STEP"

if [ -d /tmp/${NAME} ]; then
	rm -r /tmp/${NAME}
fi
mkdir /tmp/${NAME}

prefimg="/tmp/${NAME}/${NAME}_"
inx=0;

while [[ $INI -ge 0 ]];
do
	img="$prefimg$(printf "%03d" "$inx").png"
	CROP="${WIDTH}x${H}+${INI}+0"
#	echo convert "$FILE" -crop $CROP +repage "$img"
	convert "$FILE" -crop $CROP +repage "$img" > /dev/null
	((inx++))
	INI=$((INI-STEP))
done


convert -dispose background -delay $DELAY -loop 0 ${prefimg}*.png $OUTPUT > /dev/null
