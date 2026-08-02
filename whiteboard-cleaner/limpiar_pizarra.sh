#!/bin/bash

# limpiar_pizarra.sh - Limpia foto de pizarra con ImageMagick 'convert'
# Uso: ./limpiar_pizarra.sh entrada.jpg salida.png

if [ $# -ne 2 ]; then
    echo "Uso: $0 <imagen_entrada> <imagen_salida>"
    exit 1
fi

ENTRADA="$1"
SALIDA="$2"

if [ ! -f "$ENTRADA" ]; then
    echo "Error: $ENTRADA no existe."
    exit 1
fi

convert "$ENTRADA" \
    -morphology Convolve DoG:15,100,0 \
    -negate \
    -normalize \
    -blur 0x1 \
    -channel RGB \
    -level 60%,91%,0.1 \
    "$SALIDA"

echo "Imagen limpiada guardada en: $SALIDA"
