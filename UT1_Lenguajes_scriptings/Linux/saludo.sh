#!/bin/bash
#=======================
#Nombre:salido.sh
#Descripcion:Muestra un saludo personalizado por pantalla
#Autor:Alicia Sainz 
#Fecha:03/11/2025
#Comentario:
#=======================
if [ $# -eq 0 ]
then
    echo "No tengo un nombre"
    exit 1
fi
NOMBRE=$1
echo "Hola $NOMBRE"