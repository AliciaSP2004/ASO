#!/bin/bash
#=======================
#Nombre:backup.sh
#Descripcion:Realiza una copia de seguridad de un directorio
#Autor:Alicia Sainz 
#Fecha:05/11/2025
#Comentario:
#=======================
if [ -ne "$2" ]; then
    echo "Uso: $0 /ruta/origen /ruta/backup"
    exit 1
fi
ORIGEN="$1"
DESTINO="$1"
if [ ! -d "$ORIGEN" ]; then
    echo "Error: La carpeta de origen no existe"
    exit 1
fi
if [ ! -d "$DESTINO" ]; then
    echo "Error: La carpeta de destino no existe.Creandola..."
    mkdir -p "$DESTINO"
fi
echo "Indicando copia de archivos desde $ORIGEN hacia $DESTINO..."
FOR FICHERO IN "$ORIGEN"/*; do
    if [-f "$fichero"]; then 
            nombre=$(basename "$fichero")
            cp "$fichero" "$DESTINO"/
            if [ $? -eq 0 ]; then
            echo "Copiado: $nombre"
        else
            echo "Error al copiar: $nombre"
        fi
    fi
done

echo "Copia finalizada."
