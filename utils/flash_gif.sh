#!/bin/bash

## Analizar opciones de línea de comandos
#OPTS=$(getopt -o hc --long help,color -n'make_gif.sh' -- "$@")
OPTSARG="R:M:m:r:d:f:h --long rep:max:min:fps:delay:,file:,help"
OPTS=$(getopt -o $OPTSARG -n $0 -- "$@")

if [ $? -ne 0 ]; then
  echo "Error al analizar opciones" >&2
  exit 1
fi

## Restablecer los parámetros posicionales a las opciones analizadas
eval set -- "$OPTS"

## Inicializar variables
EXT="gif"
DELAY="10"
FPS=false
FILE=false
MAX=5
MIN=2
REP=10

## Procesar las opciones
while true; do
	case "$1" in
	-h | --help)
		echo "AYUDA: $0 $OPTSARG"
		exit 0 ;;
	-f | --file)
		FILE="$2"
		shift 2 ;;
	-d | --delay)
		if [[ $2 =~ ^[0-9]+$ ]]; then DELAY="$2"; fi
		shift 2 ;;
	-M | --max)
		if [[ $2 =~ ^[0-9]+$ ]]; then MAX="$2"; fi
		shift 2 ;;
	-m | --min)
		if [[ $2 =~ ^[0-9]+$ ]]; then MIN="$2"; fi
		shift 2 ;;
	-R | --rep)
		if [[ $2 =~ ^[0-9]+$ ]]; then REP="$2"; fi
		shift 2 ;;
	-r | --fps)
		if [[ $2 =~ ^[0-9]+$ ]]; then FPS="$2"; fi
		shift 2 ;;
	--)
		shift
		break ;;
	*)
		echo "ERROR: $0 $OPTSARG"
		exit 1 ;;
	esac
done

if [ $FILE == false ]; then FILE="/tmp/output.gif"; fi

PTH=`dirname "$FILE"`
FULLNAME="${FILE##*/}"
NAME="${FULLNAME%.*}"

if [[ $# -lt 1 ]]; then 
	while IFS= read -r line ;
	do
		echo "LINE=$line"
		items+=("$line")
		echo "ITEMS=${items[@]}"
	done 
elif [[ $# -lt 2 ]]; then
	echo "FALTAN PARAMETROS ($#)"
	exit 2
else
	items=($@)
fi

[ $MAX -lt $MIN ] && { echo "MAX=$MAX es menor que MIN=$MIN" ; exit 3 ;}

TMPNAME="/tmp/${NAME}"
[ -d ${TMPNAME} ] && rm -r ${TMPNAME}
mkdir ${TMPNAME}

inx=0
cnt=0

echo "BIENNN::::"

echo "ITEMS(${#items[@]}):${items[@]}" "ITEM0=${items[0]} ITEM1=${items[1]}" 

while [ $cnt -lt $REP ]
do

	IT=${items[$cnt%${#items[@]}]}
	NIT=$(($RANDOM%($MAX-$MIN+1)+$MIN))
	echo "IT=$IT NIT=$NIT repetido $(($NIT-$MIN+1)) veces"
	RANGE="{$MIN..$NIT}"
	echo $RANGE
	for i in `eval echo "{$MIN..$NIT}"`
	do
		ln $IT ${TMPNAME}/${NAME}_$(printf "%03d" "$inx").png
		((inx++))
	done
	((cnt++))
done

convert -dispose background -delay $DELAY -loop 0 ${TMPNAME}/${NAME}_*.png $FILE > /dev/null

echo "RESULTADO EN FICHERO: $FILE"

