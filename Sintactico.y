// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "Lista.h"
#include "Pila.h"
#include "Tercetos.h"

typedef enum {
    false = 0,
    true = 1
} bool;

int yystopparser=0;
FILE  *yyin;
extern char* yytext;
int yyerror();
int yylex();
tLista listaSimbolos;
t_pila pilaInit;
bool apilarInd = false;
bool pantalla = false;
bool numEncontrado = false;
char nombre[200];
char valor[200];
char tipo[200];
int longitud;

int Eind;
int Tind;
int Find;
int CADind;
int Aind;
int condInd;
int BIind;

char EindC[50];
char readWrite[50];
char TindC[50];
char FindC[50];
char CADindC[50];
char AindC[50];
char WHind[50];
char condIndC[50];
char condMultIndC[50];
char etiquetaCond[50];
char escribirT[50];
char numeroABuscar[50];
%}

%union{
    /* Aca dentro se definen los campos de la variable yylval */
    char* strVal; 
}

/* Palabras Reservadas */
%token IF
%token ELSE
%token WHILE
%token INTEGER
%token FLOAT
%token STRING
%token WRITE
%token READ
%token INIT
%left AND
%left OR
%token NOT

%token <strVal> CONST_INTEGER
%token <strVal> IDENTIFICADOR
%token FIN_SENTENCIA

%token <strVal> CONST_FLOAT
%token <strVal> CONST_CADENA

/* Operadores */
%right OP_IGUAL
%left OP_SUMA OP_RESTA
%left OP_MULT OP_DIV
%token OP_MAYOR
%token OP_MENOR
%token OP_MAYORIGUAL
%token OP_MENORIGUAL
%token OP_COMP_IGUAL
%token OP_NEGACION
%token OP_DISTINTO
%token AND
%token UNTILLOOP
%token BUSCOYREEMPLAZO

/* Comentarios */
%token COMENTARIO_A
%token COMENTARIO_C 
%token COMENTARIO

/* Llaves, parentensis,*/
%token LLAVE_A
%token LLAVE_C
%token PARENTESIS_A
%token PARENTESIS_C
%token CORCHETE_A
%token CORCHETE_C
%token OP_DOSPUNTOS
%token CHAR_COMA
%token CHAR_PUNTOYCOMA

%%
programa_final: programa    {printf("\nLa expresion es correcta\n");}
                            ;
                            
programa: sentencia
          ;

sentencia:  inicio_declaracion cantidad_lineas{printf("\nRegla Init \n");
                                }
            ;

cantidad_lineas: cantidad_lineas comienzo_gramatica
                | comienzo_gramatica

comienzo_gramatica: asignacion      {printf("\nRegla Asig \n");
                                    }                
                    | while         {printf("\nRegla While \n");
                                    }
                    | leer          {printf("\nRegla Leer \n");
                                    }
                    | escribir      {printf("\nRegla Display \n");
                                    }             
                    | if            {printf("\nRegla If \n");
                                    }
                    | untilLoop         {printf("\nRegla UntilLoop \n");
                                        }
                    | buscoYReemplazo     {printf("\nRegla BuscoYReemplazo \n");
                                    }
                    ;

asignacion: 
            IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL expresion     {sprintf(EindC, "%d", Eind); Aind = crearTerceto(":=", $1, EindC);} 
            | IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL const_string  {sprintf(CADindC, "%d", CADind); Aind = crearTerceto(":=", $1, CADindC);}
            ;

while: WHILE {apilarInd = true;} cond_completa LLAVE_A cantidad_lineas LLAVE_C {desapilar(&pilaInit, WHind); crearTerceto("BI", WHind, ""); modificarTerceto_saltoCondicional(condInd); apilarInd = false;}
       ;

if: IF cond_completa LLAVE_A cantidad_lineas LLAVE_C {BIind = crearTerceto("BI", "", ""); modificarTerceto_saltoCondicional(condInd);} ELSE LLAVE_A cantidad_lineas LLAVE_C {modificarTerceto_saltoCondicional(BIind);}
    |IF cond_completa LLAVE_A cantidad_lineas LLAVE_C {modificarTerceto_saltoCondicional(condInd);}
            ; 

leer: READ PARENTESIS_A expresion PARENTESIS_C {sprintf(readWrite, "%d", Eind); crearTerceto("READ", readWrite, "");}
      | READ PARENTESIS_A {pantalla = true;} const_string PARENTESIS_C {strcpy(escribirT, eliminarComillas(valor)); crearTerceto("READ", escribirT, ""); pantalla = false;}
          ;

escribir: WRITE PARENTESIS_A expresion PARENTESIS_C {sprintf(readWrite, "%d", Eind); crearTerceto("WRITE", readWrite, "");}
          | WRITE PARENTESIS_A {pantalla = true;} const_string PARENTESIS_C {strcpy(escribirT, eliminarComillas(valor)); crearTerceto("WRITE", escribirT, ""); pantalla = false;}
          ;

const_string: CONST_CADENA { strcpy(valor, yytext); strcpy(nombre, "_");
    strcat(nombre, eliminarComillas(valor)); insertarEnOrden(&listaSimbolos,nombre,"",valor,strlen(eliminarComillas(valor)) ? strlen(eliminarComillas(valor)) : 0); 
    if(pantalla == false){CADind = crearTerceto(yytext, "", "");};}
             ;

numero_real: CONST_INTEGER { strcpy(nombre, "_");
    strcat(nombre, yytext); insertarEnOrden(&listaSimbolos,nombre,"",yytext,0); Find = crearTerceto(yytext,"","");}
             | CONST_FLOAT { strcpy(nombre, "_");
    strcat(nombre, yytext); insertarEnOrden(&listaSimbolos,nombre,"",yytext,0); Find = crearTerceto(yytext,"","");}
             ;

cond_completa: PARENTESIS_A cond_completa AND {sprintf(condIndC, "%d", condInd); apilar(&pilaInit, condIndC);} cond_completa PARENTESIS_C {sprintf(condIndC, "%d", condInd); desapilar(&pilaInit, condMultIndC); crearTerceto("AND", condIndC, condMultIndC); condInd = crearTerceto("BFALSE", "", "");}
                | PARENTESIS_A cond_completa OR {sprintf(condIndC, "%d", condInd); apilar(&pilaInit, condIndC);} cond_completa PARENTESIS_C {sprintf(condIndC, "%d", condInd); desapilar(&pilaInit, condMultIndC); crearTerceto("OR", condIndC, condMultIndC); condInd = crearTerceto("BFALSE", "", "");}
                | PARENTESIS_A cond PARENTESIS_C
                | PARENTESIS_A NOT PARENTESIS_A cond PARENTESIS_C PARENTESIS_C {if(strcmp(etiquetaCond, "BEQ") == 0){modificarTerceto_etiquetaCond("BNE", condInd);};
                                                                                if(strcmp(etiquetaCond, "BNE") == 0){modificarTerceto_etiquetaCond("BEQ", condInd);};
                                                                                if(strcmp(etiquetaCond, "BLE") == 0){modificarTerceto_etiquetaCond("BGT", condInd);};
                                                                                if(strcmp(etiquetaCond, "BLT") == 0){modificarTerceto_etiquetaCond("BGE", condInd);};
                                                                                if(strcmp(etiquetaCond, "BGE") == 0){modificarTerceto_etiquetaCond("BLT", condInd);};
                                                                                if(strcmp(etiquetaCond, "BGT") == 0){modificarTerceto_etiquetaCond("BLE", condInd);};}
                ;

cond: expresion OP_DISTINTO termino {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BEQ"); condInd = crearTerceto(etiquetaCond, "", "");}
    | expresion OP_IGUAL termino    {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BNE"); condInd = crearTerceto(etiquetaCond, "", "");}
    | expresion OP_MAYOR termino    {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BLE"); condInd = crearTerceto(etiquetaCond, "", "");}
    | expresion OP_MAYORIGUAL termino {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BLT"); condInd = crearTerceto(etiquetaCond, "", "");}
    | expresion OP_MENOR termino     {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BGE"); condInd = crearTerceto(etiquetaCond, "", "");}
    | expresion OP_MENORIGUAL termino {sprintf(EindC, "%d", Eind); if(apilarInd == true){apilar(&pilaInit, EindC);}; sprintf(TindC, "%d", Tind); crearTerceto("CMP", EindC, TindC); strcpy(etiquetaCond, "BGT"); condInd = crearTerceto(etiquetaCond, "", "");}
    ;

expresion:
        expresion OP_SUMA termino {sprintf(EindC, "%d", Eind); sprintf(TindC, "%d", Tind); Eind = crearTerceto("+", EindC, TindC);}
        |expresion OP_RESTA termino {sprintf(EindC, "%d", Eind); sprintf(TindC, "%d", Tind); Eind = crearTerceto("-", EindC, TindC);}
        |termino   {Eind = Tind;}
        ;

termino: 
       factor {Tind = Find;}
       |termino OP_MULT factor {sprintf(TindC, "%d", Tind); sprintf(FindC, "%d", Find); Tind = crearTerceto("*", TindC, FindC);}
       |termino OP_DIV factor  {sprintf(TindC, "%d", Tind); sprintf(FindC, "%d", Find); Tind = crearTerceto("/", TindC, FindC);}
       ;

factor: 
      IDENTIFICADOR  {Find = crearTerceto(yytext,"","");}
      | numero_real
        | PARENTESIS_A expresion PARENTESIS_C {Find = Eind;}
        ;

inicio_declaracion: INIT LLAVE_A filas LLAVE_C
                    ;   

filas: fila_variables filas
       | fila_variables
       ;


            
fila_variables:  IDENTIFICADOR CHAR_COMA fila_variables {insertarEnOrden(&listaSimbolos,$1,tipo,"",0);} 
                | IDENTIFICADOR OP_DOSPUNTOS tipo {
                                                    insertarEnOrden(&listaSimbolos,$1,tipo,"",0); 
                                                   }
                ;
                
tipo: INTEGER  {strcpy(tipo,"INTEGER");}
    | FLOAT {strcpy(tipo,"FLOAT");}
    | STRING {strcpy(tipo,"STRING");}
    ;

untilLoop: 
        UNTILLOOP {apilarInd = true;} PARENTESIS_A cond {if(strcmp(etiquetaCond, "BEQ") == 0){modificarTerceto_etiquetaCond("BNE", condInd);};
                                                         if(strcmp(etiquetaCond, "BNE") == 0){modificarTerceto_etiquetaCond("BEQ", condInd);};
                                                         if(strcmp(etiquetaCond, "BLE") == 0){modificarTerceto_etiquetaCond("BGT", condInd);};
                                                         if(strcmp(etiquetaCond, "BLT") == 0){modificarTerceto_etiquetaCond("BGE", condInd);};
                                                         if(strcmp(etiquetaCond, "BGE") == 0){modificarTerceto_etiquetaCond("BLT", condInd);};
                                                         if(strcmp(etiquetaCond, "BGT") == 0){modificarTerceto_etiquetaCond("BLE", condInd);};}
                                                        CHAR_COMA asignacion PARENTESIS_C {desapilar(&pilaInit, WHind); crearTerceto("BI", WHind, ""); modificarTerceto_saltoCondicional(condInd); apilarInd = false;}
        ;

buscoYReemplazo:
        IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL BUSCOYREEMPLAZO PARENTESIS_A CONST_INTEGER {strcpy(numeroABuscar, yytext);} CHAR_COMA CORCHETE_A listaNumeros CORCHETE_C PARENTESIS_C 
        {if(numEncontrado == true){crearTerceto(":=", $1, numeroABuscar);}; if(numEncontrado == false){crearTerceto("PANTALLA", "numero no encontrado", "");};}
                   ;

listaNumeros: listaNumeros CHAR_COMA CONST_INTEGER {if(strcmp(yytext, numeroABuscar) == 0){numEncontrado = true;};}
        | CONST_INTEGER {if(strcmp(yytext, numeroABuscar) == 0){numEncontrado = true;};}

%%


int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return 1;
       
    }
    else
    { 
        printf("\n El archivo %s se abrio correctamente\n", argv[1]);
        crearLista(&listaSimbolos);
        crear_pila(&pilaInit);
        yyparse();
        eliminarTabla(&listaSimbolos);
        imprimirTercetos();
        vaciar_pila(&pilaInit);
    }

   printf("\nFLEX finalizo la lectura del archivo %s \n", argv[1]);
     fclose(yyin);
   return 0;
}

/*
int yyerror(void)
     {
       printf("Error Sintactico %s\n",yytext);
         exit (1);
     }
*/