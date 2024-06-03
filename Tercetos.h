#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TERCETOS 200

// Estructura para representar un terceto
typedef struct {
    char operador[50];
    char operando1[50];
    char operando2[50];
} Terceto;

// Arreglo para almacenar los tercetos
Terceto tercetos[MAX_TERCETOS];

// Índice actual de terceto
int terceto_index = 0;
int cant_tercetos = 0; 

// Función para crear un terceto y retornar su índice
int crearTerceto(char operador[], char op1[], char op2[]) {
    if (terceto_index >= MAX_TERCETOS) {
        printf("Error: Se ha excedido el límite de tercetos\n");
        exit(EXIT_FAILURE);
    }

    strcpy(tercetos[terceto_index].operador, operador);
    strcpy(tercetos[terceto_index].operando1, op1);
    strcpy(tercetos[terceto_index].operando2, op2);

    cant_tercetos++;

    return terceto_index++;
}

modificarTerceto_etiquetaCond(char etiqueta[], int indice){
    strcpy(tercetos[indice].operador, etiqueta);
}

modificarTerceto_saltoCondicional(int indice){
    char indActual[50];
    sprintf(indActual, "%d", terceto_index);
    strcpy(tercetos[indice].operando1, indActual);
}

void imprimirTercetos()
{
    FILE *archivo;
    archivo = fopen("Tercetos.txt", "w+");

    if (!archivo) {
        printf("Error al abrir el archivo.");
        return;
    }

    int i = 0;
    while (i < cant_tercetos) {
        fprintf(archivo, "[%d] (%s, %s, %s)\n", i, tercetos[i].operador, tercetos[i].operando1, tercetos[i].operando2);
        i++;
    }

    fclose(archivo);
}