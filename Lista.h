#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIN_MEM 0
#define EXITO 1
#define DUPLICADO 2


typedef struct sNodo
{
    char nombre[50];
    char tipo[50];
    char valor[50];
    int  longitud;
    struct sNodo* sig;
}tNodo;

typedef tNodo* tLista;

void crearLista(tLista *p);
void mostrarLista(tLista *p);
int insertarEnOrden(tLista *p, char* nombre, char* tipo, char* valor, int longitud);

/* Del ID guardamos nombre y tipo de dato solamente. Su valor se establece en tiempo de ejecución */
int insertarID(tLista *p, char* nombre, char* tipo,char* valor); 


/* Constantes. Guardamos nombre, y su valor (en el caso de los String guardamos tambien su longitud) */
int insertarString(tLista *p, char* nombre);
int insertarInt(tLista *p, char* lexema);
int insertarFloat(tLista *p, char* lexema);

void imprimirEncabezado(FILE *puntTabla);
void eliminarTabla(tLista *p);
char* eliminarComillas(char* stringRecibido);



void crearLista(tLista *p)
{
    *p = NULL;
}

void mostrarLista(tLista *p)
{
    printf("\nContenido de la lista\n");
    while(*p)
    {
        printf("%s\n",(*p)->nombre);
        p = &(*p)->sig;
    }
}

int insertarEnOrden(tLista *p, char* nombre, char* tipo, char* valor, int longitud)
{
    int result = -1;
    tNodo* nue = (tNodo*)malloc(sizeof(tNodo));
    
    if(!nue)
        return SIN_MEM;

    while(*p && ((result = (strcmp((*p)->nombre, nombre))) < 0)){
    //printf("Reviso result: %d \n",result);
    //      printf("Reviso lista: %s ------ %s\n",(*p)->nombre, nombre);
        p = &(*p)->sig;
    }

    if(result == 0)
    {
        strcpy((*p)->valor, valor);
        strcpy((*p)->tipo, tipo);
        (*p)->longitud = longitud;
        return DUPLICADO;

    }
    strcpy(nue->nombre, nombre);
    strcpy(nue->tipo, tipo);
    strcpy(nue->valor, valor);
    nue->longitud = longitud;

    nue->sig = *p;

    *p = nue;

    return EXITO;
}

/* En este caso el lexema que recibimos es lo que nos da yytext */
int insertarInt(tLista *p, char* lexema) 
{
    return 0;
//     int result = -1;
//     char nombreInsertar[100];

//     /* Como en la TS debemos mostrar el nombre el lexema con _ delante, se lo agregamos y así lo mandamos a la lista */
//     strcpy(nombreInsertar, "_");
//     strcat(nombreInsertar, lexema); 

//     /* El tipo no se muestra en CTES en la TS. Por eso en lugar del parámetro tipo ponemos */
//    // result = insertarEnOrden(p, nombreInsertar, " ", lexema, 0);

//     /* Para el caso de int, float y string, podemos tener una misma CTE y eso no significa que esté mal, solamente que se repite en el código y debemos almacenarla una sola vez */
//     if(result == DUPLICADO)
//         {
//             printf("El lexema *%s* ya se encuentra dentro de la tabla de simbolos. No se ingresara\n", lexema);
//             return DUPLICADO;
//         }

    return EXITO;
}

int insertarFloat(tLista *p, char* lexema) 
{
    int result = -1;
    char nombreInsertar[100];

    /* Como en la TS debemos mostrar el nombre (el lexema) con _ delante, se lo agregamos y así lo mandamos a la lista */
    strcpy(nombreInsertar, "_");
    strcat(nombreInsertar, lexema); 

    /* El tipo no se muestra en CTES en la TS. Por eso en lugar del parámetro tipo ponemos "" */
    result = insertarEnOrden(p, nombreInsertar, " " , lexema, 0);

    /* Para el caso de int, float y string, podemos tener una misma CTE y eso no significa que esté mal, solamente que se repite en el código y debemos almacenarla una sola vez */
    if(result == DUPLICADO)
        {
            printf("El lexema *%s* ya se encuentra dentro de la tabla de simbolos. No se ingresara\n", lexema);
            return DUPLICADO;
        }

    return EXITO;
}

int insertarString(tLista *p, char* lexema)
{
    int result = -1;
    char nombreInsertar[100];

    /* El valor de un string es la misma cadena pero sin las comillas en la TS */
    char* valorInsertar = eliminarComillas(lexema);

    /* El nombre de un string es la misma cadena con un "_" delante */
    strcpy(nombreInsertar, "_");
    strcat(nombreInsertar, valorInsertar);

    /* El tipo no se muestra en CTES en la TS. Por eso en lugar del parámetro tipo ponemos "" */
    result = insertarEnOrden(p, nombreInsertar, " ", valorInsertar, strlen(valorInsertar));

    if(result == DUPLICADO)
        {
            printf("El lexema *%s* ya se encuentra dentro de la tabla de simbolos. No se ingresara\n", lexema);
            return DUPLICADO;
        }

    return EXITO;
}

char* eliminarComillas(char* stringRecibido)
{
    char* cad = stringRecibido;
    char* cadInicio = cad;
    while(*stringRecibido)
    {
        if(*stringRecibido != '"')
        {
            (*cad) = (*stringRecibido);
            cad++;
        }
        
        stringRecibido++;
    }

    *cad = '\0';
    return cadInicio;
}

int insertarID(tLista *p, char* lexema, char* tipo, char* valor)
{
    int result = -1;

    result = insertarEnOrden(p, lexema, tipo, valor, 0);
    if(result == DUPLICADO)
        {
            printf("El lexema *%s* ya se encuentra dentro de la tabla de simbolos. No se ingresara\n", lexema);
            return DUPLICADO;
        }

    return EXITO;
}

void eliminarTabla(tLista *p)
{


    FILE *puntTabla = fopen("SymbolTable.txt", "w+");
    if(!puntTabla)
    {
        printf("No se pudo abrir el archivo \"SymbolTable.txt\"\n");
        return;
    }



    imprimirEncabezado(puntTabla);

 

    while(*p)
    {
        //printf("|%-30s|%-14s|%-30s|%-14d|\n", (*p)->nombre, (*p)->tipo, (*p)->valor, (*p)->longitud));
        if((*p)->longitud > 0){
            fprintf(puntTabla, "|%-30s|%-14s|%-30s|%-14d|\n", (*p)->nombre, (*p)->tipo, (*p)->valor, (*p)->longitud);
        }
        else{
            fprintf(puntTabla, "|%-30s|%-14s|%-30s|%-14s|\n", (*p)->nombre, (*p)->tipo, (*p)->valor, "");
        }
        
        tLista temp = *p;
        p = &(*p)->sig;
        free(temp);
    }

    fprintf(puntTabla, "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n");

    fclose(puntTabla);
}

void imprimirEncabezado(FILE *puntTabla)
{
    fprintf(puntTabla, "_____________________________________________________________________________________________\n");
    fprintf(puntTabla, "|%-30s|%-14s|%-30s|%-14s|\n", "NOMBRE", "TIPO DE DATO", "VALOR", "LONGITUD");
    fprintf(puntTabla, "¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\n");
}