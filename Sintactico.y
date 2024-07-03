// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "y.tab.h"
#include "Lista.h"
#include "Pila.h"
#include "Tercetos.h"

int yystopparser=0;
FILE  *yyin;
extern char* yytext;
int yyerror();
int yylex();
tLista listaSimbolos;
t_pila pilaInit;

int crearEtiquetaEnTerceto();

bool apilarInd = false;
bool pantalla = false;
bool numEncontrado = false;
bool condMult = false;

char nombre[200];
char valor[200];
char tipo[200];
char tipoLadoIzq[200];
char tipoLadoDer[200];
int longitud;

int Eind;
int Tind;
int Find;
int CADind;
int Aind;
int condInd;
int condIzqInd;
int BIind;
int condMultInd;
int pivotInd;
int auxInd;
int saltInd;
int ifAnidadoInd;
int indexTerceto;
int indWH;

char EindC[50];
char readWrite[50];
char TindC[50];
char FindC[50];
char CADindC[50];
char AindC[50];
char WHind[50];
char condIndC[50];
char condIzqIndC[50];
char condMultIndC[50];
char etiquetaCond[50];
char escribirT[50];
char numeroABuscar[50];
char pivotIndC[50];
char auxIndC[50];
char etiqueta[50];
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
programa_final: programa    {printf("\nLa expresion es correcta\n"); generar_assembler(&listaSimbolos);}
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
            IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);};} expresion {sprintf(EindC, "[%d]", Eind); Aind = crearTerceto(":=", $1, EindC);}
            | IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);};} const_string  {sprintf(CADindC, "[%d]", CADind); Aind = crearTerceto(":=", $1, CADindC);}
            ;

while: WHILE {indWH = crearEtiquetaEnTerceto();} cond_completa LLAVE_A cantidad_lineas LLAVE_C {sprintf(WHind, "[%d]", indWH); crearTerceto("BI", WHind, ""); desapilarTercetos(); modificarTerceto_saltoCondicional(condInd); crearEtiquetaEnTerceto();}
       ;

if: IF cond_completa LLAVE_A cantidad_lineas LLAVE_C {BIind = crearTerceto("BI", "", ""); if((condInd = desapilarTercetos()) != -1){modificarTerceto_saltoCondicional(condInd);}; crearEtiquetaEnTerceto();} ELSE LLAVE_A cantidad_lineas LLAVE_C {modificarTerceto_saltoCondicional(BIind); crearEtiquetaEnTerceto();}
    |IF cond_completa LLAVE_A cantidad_lineas LLAVE_C {if((condInd = desapilarTercetos()) != -1){modificarTerceto_saltoCondicional(condInd);}; crearEtiquetaEnTerceto(); if(condMult == true){modificarTerceto_saltoCondicional(condMultInd); crearEtiquetaEnTerceto(); condMult = false;};}
            ; 

leer: READ PARENTESIS_A IDENTIFICADOR PARENTESIS_C {if(buscarEnLista(&listaSimbolos, $3, NULL) == false){yyerrorNoExisteVariable($3);}; crearTerceto("READ", $3, "");}
      | READ PARENTESIS_A CONST_CADENA PARENTESIS_C {strcpy(valor, $3); strcpy(nombre, "_");
                                                     strcat(nombre, eliminarComillas(valor)); insertarEnOrden(&listaSimbolos,nombre,"",valor,strlen(eliminarComillas(valor)) ? strlen(eliminarComillas(valor)) : 0); crearTerceto("READ", valor, "");}
          ;

escribir: WRITE PARENTESIS_A IDENTIFICADOR PARENTESIS_C {if(buscarEnLista(&listaSimbolos, $3, NULL) == false){yyerrorNoExisteVariable($3);}; crearTerceto("WRITE", $3, "");}
          | WRITE PARENTESIS_A CONST_CADENA {strcpy(valor, yytext); strcpy(nombre, "_");
                                             strcat(nombre, eliminarComillas(valor)); insertarEnOrden(&listaSimbolos,nombre,"",valor,strlen(eliminarComillas(valor)) ? strlen(eliminarComillas(valor)) : 0); crearTerceto("WRITE", valor, "");} PARENTESIS_C
          ;

const_string: CONST_CADENA {if(strcmp(tipoLadoIzq, "STRING") != 0){yyerrorTiposEntreIds(yytext);}; strcpy(valor, yytext); strcpy(nombre, "_");
                             strcat(nombre, eliminarComillas(valor)); insertarEnOrden(&listaSimbolos,nombre,"STRING",valor,strlen(eliminarComillas(valor)) ? strlen(eliminarComillas(valor)) : 0); 
                             CADind = crearTerceto(nombre, "", "");}
             ;

numero_real: CONST_INTEGER {if(strcmp(tipoLadoIzq, "INTEGER") != 0){yyerrorTiposEntreIds(yytext);}; strcpy(nombre, "_");
    strcat(nombre, yytext); insertarEnOrden(&listaSimbolos,nombre,"INTEGER",yytext,0); Find = crearTerceto(nombre,"","");}
             | CONST_FLOAT {if(strcmp(tipoLadoIzq, "FLOAT") != 0){yyerrorTiposEntreIds(yytext);}; strcpy(nombre, "_");
    strcat(nombre, yytext); insertarEnOrden(&listaSimbolos,nombre,"FLOAT",yytext,0); Find = crearTerceto(nombre,"","");}
             ;

cond_completa: PARENTESIS_A cond_completa AND {condMultInd = desapilarTercetos(); condMult = true;} cond_completa PARENTESIS_C
                | PARENTESIS_A cond_completa OR {modificarTerceto_etiquetaCond(etiquetaCond, condInd); condMultInd = desapilarTercetos();} cond_completa PARENTESIS_C {modificarTerceto_saltoCondicional(condMultInd); crearEtiquetaEnTerceto();}
                | PARENTESIS_A cond PARENTESIS_C
                | PARENTESIS_A NOT PARENTESIS_A cond PARENTESIS_C PARENTESIS_C {modificarTerceto_etiquetaCond(etiquetaCond, condInd);}
                ;

cond: IDENTIFICADOR OP_DISTINTO {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BEQ"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    | IDENTIFICADOR OP_IGUAL {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion    {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BNE"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    | IDENTIFICADOR OP_MAYOR {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion    {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BLE"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    | IDENTIFICADOR OP_MAYORIGUAL {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BLT"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    | IDENTIFICADOR OP_MENOR {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion     {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BGE"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    | IDENTIFICADOR OP_MENORIGUAL {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);}else{condIzqInd = crearTerceto($1, "", "");};} expresion {sprintf(condIzqIndC, "[%d]", condIzqInd); sprintf(EindC, "[%d]", Eind); crearTerceto("CMP", condIzqIndC, EindC); strcpy(etiquetaCond, "BGT"); condInd = crearTerceto(etiquetaCond, "", ""); apilarTercetos(condInd);}
    ;

expresion:
        expresion OP_SUMA termino {sprintf(EindC, "[%d]", Eind); sprintf(TindC, "[%d]", Tind); Eind = crearTerceto("+", EindC, TindC);}
        |expresion OP_RESTA termino {sprintf(EindC, "[%d]", Eind); sprintf(TindC, "[%d]", Tind); Eind = crearTerceto("-", EindC, TindC);}
        |termino   {Eind = Tind;}
        ;

termino: 
       factor {Tind = Find;}
       |termino OP_MULT factor {sprintf(TindC, "[%d]", Tind); sprintf(FindC, "[%d]", Find); Tind = crearTerceto("*", TindC, FindC);}
       |termino OP_DIV factor  {sprintf(TindC, "[%d]", Tind); sprintf(FindC, "[%d]", Find); Tind = crearTerceto("/", TindC, FindC);}
       ;

factor: 
      IDENTIFICADOR  {if(buscarEnLista(&listaSimbolos, yytext, tipoLadoDer) == false){yyerrorNoExisteVariable(yytext);}; if(strcmp(tipoLadoIzq, tipoLadoDer) != 0){yyerrorTiposEntreIds(yytext);}; Find = crearTerceto(yytext,"","");}
      | numero_real
        | PARENTESIS_A expresion PARENTESIS_C {Find = Eind;}
        ;

inicio_declaracion: INIT LLAVE_A filas LLAVE_C
                    ;   

filas: fila_variables filas
       | fila_variables
       ;


            
fila_variables:  IDENTIFICADOR CHAR_COMA fila_variables {if(insertarEnOrden(&listaSimbolos,$1,tipo,"",0) == DUPLICADO){yyerrorVariablesDuplicadas($1);};} 
                | IDENTIFICADOR OP_DOSPUNTOS tipo {
                                                    if(insertarEnOrden(&listaSimbolos,$1,tipo,"",0) == DUPLICADO){yyerrorVariablesDuplicadas($1);}; 
                                                   }
                ;
                
tipo: INTEGER  {strcpy(tipo,"INTEGER");}
    | FLOAT {strcpy(tipo,"FLOAT");}
    | STRING {strcpy(tipo,"STRING");}
    ;

untilLoop: 
        UNTILLOOP {indWH = crearEtiquetaEnTerceto();} PARENTESIS_A cond {modificarTerceto_etiquetaCond(etiquetaCond, condInd);}
                                                        CHAR_COMA asignacion PARENTESIS_C {sprintf(WHind, "[%d]", indWH); crearTerceto("BI", WHind, ""); desapilarTercetos(); modificarTerceto_saltoCondicional(condInd); crearEtiquetaEnTerceto();}
        ;

buscoYReemplazo:
        IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL BUSCOYREEMPLAZO PARENTESIS_A CONST_INTEGER {if(buscarEnLista(&listaSimbolos, $1, tipoLadoIzq) == false){yyerrorNoExisteVariable($1);};
                                                                                        if(strcmp(tipoLadoIzq, "INTEGER") != 0){yyerrorTiposEntreIds($1);};
                                                                                        strcpy(nombre, "_"); strcat(nombre, yytext); strcpy(numeroABuscar, nombre); crearTerceto(":=", "@pivot", numeroABuscar); insertarEnOrden(&listaSimbolos,nombre,"",yytext,0); insertarEnOrden(&listaSimbolos,"@pivot","INTEGER", "",0);}
                                                                                      CHAR_COMA CORCHETE_A listaNumeros CORCHETE_C PARENTESIS_C 
        {crearTerceto("WRITE", "numero no encontrado", ""); BIind = crearTerceto("BI", "", ""); while((saltInd = desapilarTercetos()) != -1){modificarTerceto_saltoCondicional(saltInd);}; crearEtiquetaEnTerceto(); crearTerceto(":=", $1, "@aux"); modificarTerceto_saltoCondicional(BIind); crearEtiquetaEnTerceto();}
                   ;

listaNumeros: listaNumeros CHAR_COMA CONST_INTEGER {strcpy(nombre, "_");
                                                    strcat(nombre, yytext); auxInd = crearTerceto(":=", "@aux", nombre); sprintf(auxIndC, "[%d]", auxInd); crearTerceto("CMP", "@pivot", "@aux"); saltInd = crearTerceto("BEQ", "", ""); apilarTercetos(saltInd); insertarEnOrden(&listaSimbolos,nombre,"",yytext,0);}
        | CONST_INTEGER {strcpy(nombre, "_");
                        strcat(nombre, yytext); auxInd = crearTerceto(":=", "@aux", nombre); sprintf(auxIndC, "[%d]", auxInd); crearTerceto("CMP","@pivot", "@aux"); saltInd = crearTerceto("BEQ", "", ""); apilarTercetos(saltInd); insertarEnOrden(&listaSimbolos,nombre,"",yytext,0); insertarEnOrden(&listaSimbolos,"@aux","INTEGER", "",0);}

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

int crearEtiquetaEnTerceto()
{
  indexTerceto = devolver_index_terceto();
  sprintf(etiqueta, "Etiq%d" , indexTerceto);
  crearTerceto(etiqueta, "", "");

  return indexTerceto;
}

int yyerrorTiposEntreIds(char* ptr)
     {
       printf("Error semantico: asignacion o comparacion (id y id o id y cte) de distinto tipos en id = %s, saliendo... \n",yytext);
         exit (1);
     }


int yyerrorNoExisteVariable(char* ptr)
     {
       printf("Error semantico: variable no declarada: %s, saliendo... \n",ptr);
       exit (1);
     }

int yyerrorVariablesDuplicadas(char* ptr)
     {
       printf("Error semantico: definicion de variables duplicadas: %s, saliendo... \n",ptr);
       exit (1);
     }

