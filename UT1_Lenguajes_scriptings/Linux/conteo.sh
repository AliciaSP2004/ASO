#!/bin/bash
#=======================
#Nombre:conteo.sh
#Descripcion:Muestra la cantidad de archivos de un directorio
#Autor:Alicia Sainz 
#Fecha:05/11/2025
#Comentario:
#=======================
if [ -z "$1" ]; then
    echo "Uso: $0 /ruta/al/directorio"
    exit 1
fi
DIRECTORIO="$1"
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: '$DIRECTORIO' no es un directorio válido."
    exit 1
fi
CONTEO=$(find "$DIRECTORIO" -type f | wc -l)
echo "📂 Número de archivos en '$DIRECTORIO': $CONTEO"
