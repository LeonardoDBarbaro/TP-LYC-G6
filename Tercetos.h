#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Lista.h"

#define MAX_TERCETOS 200

// Estructura para representar un terceto
typedef struct {
    char operador[50];
    char operando1[50];
    char operando2[50];
} Terceto;

// Arreglo para almacenar los tercetos
Terceto tercetos[MAX_TERCETOS];

int tercetosApilados[20];
int indiceTercetoApiladoActual = 0;

// Índice actual de terceto
int terceto_index = 0;
int cant_tercetos = 0;

void imprimirEncabezadoAss(FILE* archivo);
void traducirTercetosAAssembler(FILE* archivo, tLista* listaDatos);

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

int devolver_index_terceto(){
    return terceto_index;
}

void modificarTerceto_etiquetaCond(char etiqueta[], int indice){
    char condInversa[50];
    if(strcmp(etiqueta, "BEQ") == 0){strcpy(condInversa, "BNE");}
    if(strcmp(etiqueta, "BNE") == 0){strcpy(condInversa, "BEQ");}
    if(strcmp(etiqueta, "BLE") == 0){strcpy(condInversa, "BGT");}
    if(strcmp(etiqueta, "BLT") == 0){strcpy(condInversa, "BGE");}
    if(strcmp(etiqueta, "BGE") == 0){strcpy(condInversa, "BLT");}
    if(strcmp(etiqueta, "BGT") == 0){strcpy(condInversa, "BLE");}

    strcpy(tercetos[indice].operador, condInversa);
}

void modificarTerceto_saltoCondicional(int indice){
    char indActual[50];
    sprintf(indActual, "[%d]", terceto_index);
    strcpy(tercetos[indice].operando1, indActual);
}

void apilarTercetos(int t){
    indiceTercetoApiladoActual++;
    tercetosApilados[indiceTercetoApiladoActual] = t;
}

int desapilarTercetos(){
    int res;
    if(indiceTercetoApiladoActual == 0){
        res = -1;
    }
    else{
        res = tercetosApilados[indiceTercetoApiladoActual];
        indiceTercetoApiladoActual--;
    }
    
    return res;
}

void generar_assembler(tLista* listaSimbolos){
    FILE *archivo;
    archivo = fopen("final.asm", "w+");

    if (!archivo) {
        printf("Error al abrir el archivo.");
        return;
    }

    imprimirEncabezadoAss(archivo);
    fprintf(archivo, "\n.DATA\n");
    imprimirDataAsm(listaSimbolos, archivo);

    fprintf(archivo, "\n.CODE\n");
    fprintf(archivo, "MAIN PROC\n");

    traducirTercetosAAssembler(archivo, listaSimbolos);

    fprintf(archivo, "mov ah, 4Ch\n");
    fprintf(archivo, "mov al, 0\n");
    fprintf(archivo, "int 21h;\n");
    fprintf(archivo, "CountLength:\n");
    fprintf(archivo, "MOV AL, [SI]\n");
    fprintf(archivo, "INC SI\n");
    fprintf(archivo, "CMP AL, 0\n");
    fprintf(archivo, "JE EndCount\n");
    fprintf(archivo, "INC CX\n");
    fprintf(archivo, "JMP CountLength\n");
    fprintf(archivo, "\nEndCount:\n");
    fprintf(archivo, "RET\n");
    fprintf(archivo, "\nMAIN ENDP\n");
    fprintf(archivo, "END MAIN\n");

    fclose(archivo);
}

void imprimirEncabezadoAss(FILE* archivo){
    fprintf(archivo, "include macros2.asm\n");
    fprintf(archivo, "include numbers.asm\n");
    fprintf(archivo, ".MODEL LARGE\n");
    fprintf(archivo, ".386\n");
    fprintf(archivo, "stack 200h\n");
}

void traducirTercetosAAssembler(FILE* archivo, tLista* listaDatos){
    int i = 0;
    while(i < cant_tercetos){
        if(strcmp(tercetos[i].operador, "+") == 0){
            fprintf(archivo, "FADD\n");
        }
        else if(strcmp(tercetos[i].operador, "-") == 0){
            fprintf(archivo, "FSUB\n");
        }
        else if(strcmp(tercetos[i].operador, "*") == 0){
            fprintf(archivo, "FMUL\n");
        }
        else if(strcmp(tercetos[i].operador, "/") == 0){
            fprintf(archivo, "FDIV\n");
        }
        else if(strcmp(tercetos[i].operador, ":=") == 0){
            char tipoDeDato[20];
            buscarEnLista(listaDatos, tercetos[i].operando1, tipoDeDato);
            if(strcmp(tipoDeDato, "STRING") == 0){
                fprintf(archivo, "MOV DI, OFFSET %s\n", tercetos[i].operando1);
                fprintf(archivo, "MOV CX, 0 \n");
                fprintf(archivo, "\nCALL CountLength\n");
            }
            else{
                fprintf(archivo, "FISTP %s\n", tercetos[i].operando1);
            }
            
        }
        else if(strcmp(tercetos[i].operador, "WRITE") == 0){
            fprintf(archivo, "mov dx,OFFSET %s\n", tercetos[i].operando1);
            fprintf(archivo, "mov ah,9\n");
        }
        else if(strcmp(tercetos[i].operador, "READ") == 0){
            
        }
        else if(strcmp(tercetos[i].operador, "CMP") == 0){
            fprintf(archivo, "FXCH\n");
            fprintf(archivo, "FCOM\n");
            fprintf(archivo, "FSTSW AX\n");
            fprintf(archivo, "SAHF\n");
            fprintf(archivo, "FFREE\n");
        }
        else if(strcmp(tercetos[i].operador, "BGT") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JG Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "GBE") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JGE Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "BLT") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JL Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "BLE") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JLE Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "BEQ") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JEQ Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "BNE") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JNE Etiq%d\n", index);
        }
        else if(strcmp(tercetos[i].operador, "BI") == 0){
            int index = atoi(&tercetos[i].operando1[1]);
            fprintf(archivo, "JMP Etiq%d\n", index);
        }
        else if(strncmp(tercetos[i].operador, "Etiq", 4) == 0) {
            fprintf(archivo, "%s:\n", tercetos[i].operador);
        }
        else{
            char tipoDeDato[20];
            buscarEnLista(listaDatos, tercetos[i].operador, tipoDeDato);
            if(strcmp(tipoDeDato, "STRING") == 0){
                fprintf(archivo, "MOV SI, OFFSET %s\n", tercetos[i].operador);
            }
            else{
                fprintf(archivo, "FILD %s\n", tercetos[i].operador);
            }
        }

        i++;
    }
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