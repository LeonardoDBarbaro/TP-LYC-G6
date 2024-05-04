// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "Lista.h"
#include "Pila.h"
int yystopparser=0;
FILE  *yyin;
extern char* yytext;
int yyerror();
int yylex();
tLista listaSimbolos;
t_pila pilaInit; 
char nombre[200];
char valor[200];
char tipo[200];
int longitud;
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
%token OP_DOSPUNTOS
%token CHAR_COMA
%token CHAR_PUNTOYCOMA

%%
programa_final: programa    {printf("\nLa expresion es correcta");}
                            ;
                            
programa: sentencia
          ;

sentencia:  sentencia comienzo_gramatica CHAR_PUNTOYCOMA        
            | sentencia comienzo_gramatica        
            | comienzo_gramatica
            | inicio_declaracion CHAR_PUNTOYCOMA{printf("\nRegla Init \n");
                                } 
            | inicio_declaracion sentencia
            |{;}
            ;

comienzo_gramatica: asignacion      {printf("\nRegla Asig \n");
                                    }                
                    | while         {printf("\nRegla While \n");
                                    }
                    | leer          {printf("\nRegla Leer \n");
                                    }
                    | escribir      {printf("\nRegla Display \n") ;
                                    }             
                    | if            {printf("\nRegla If \n");
                                    }
                    | untilLoop         {printf("\nRegla UntilLoop \n");
                                        }
                    | buscoYReemplazo     {printf("\nRegla BuscoYReemplazo \n");
                                    }
                    ;

asignacion: 
            IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL expresion     { insertarEnOrden(&listaSimbolos,$1,tipo,valor,0);}   
            | IDENTIFICADOR OP_DOSPUNTOS OP_IGUAL const_string  { insertarEnOrden(&listaSimbolos,$1,tipo,valor,longitud);}     
            ;

while: WHILE cond_completa LLAVE_A sentencia LLAVE_C
       ;

if: IF cond_completa LLAVE_A sentencia LLAVE_C ELSE LLAVE_A sentencia LLAVE_C
    |IF cond_completa LLAVE_A sentencia LLAVE_C
            ; 

leer: READ PARENTESIS_A expresion PARENTESIS_C
      | READ PARENTESIS_A IDENTIFICADOR PARENTESIS_C
      | READ PARENTESIS_A const_string PARENTESIS_C

escribir: WRITE PARENTESIS_A expresion PARENTESIS_C
          | WRITE PARENTESIS_A IDENTIFICADOR PARENTESIS_C 
          | WRITE PARENTESIS_A const_string PARENTESIS_C 
          ;

const_string: CONST_CADENA {strcpy(valor,yytext); strcpy(tipo,"STRING"); longitud = (strlen(eliminarComillas(valor)) ? strlen(eliminarComillas(valor)) : 0); }

numero_real: CONST_INTEGER { strcpy(valor,yytext); strcpy(tipo,"INTEGER"); longitud = 0; }
             | CONST_FLOAT { strcpy(valor,yytext); strcpy(tipo,"FLOAT"); longitud = 0; }
             ;

cond_completa: PARENTESIS_A cond_completa AND cond_completa PARENTESIS_C
                | PARENTESIS_A cond AND cond_completa PARENTESIS_C
                | PARENTESIS_A cond_completa AND cond PARENTESIS_C
                | PARENTESIS_A cond_completa OR cond_completa PARENTESIS_C
                | PARENTESIS_A cond OR cond_completa PARENTESIS_C 
                | PARENTESIS_A cond_completa OR cond PARENTESIS_C 
                | PARENTESIS_A cond PARENTESIS_C
                | PARENTESIS_A cond AND cond PARENTESIS_C 
                | PARENTESIS_A cond OR cond PARENTESIS_C 
                | NOT cond
                | PARENTESIS_A cond_completa PARENTESIS_C 
                ;

cond: expresion OP_DISTINTO termino
    | expresion OP_IGUAL termino
    | expresion OP_MAYOR termino 
    | expresion OP_MAYORIGUAL termino
    | expresion OP_MENOR termino 
    | expresion OP_MENORIGUAL termino
    | expresion OR termino 
    | expresion AND termino
    | expresion NOT termino
    ;

expresion:
        expresion  OP_SUMA termino 
        |expresion OP_RESTA termino 
        |termino 
        ;

termino: 
       factor
       |termino OP_MULT factor
       |termino OP_DIV factor
       ;

factor: 
      IDENTIFICADOR
      | numero_real
      | PARENTESIS_A expresion PARENTESIS_C
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
        UNTILLOOP PARENTESIS_A cond CHAR_COMA asignacion PARENTESIS_C
        ;

buscoYReemplazo:
        BUSCOYREEMPLAZO PARENTESIS_A IDENTIFICADOR CHAR_COMA IDENTIFICADOR CHAR_COMA IDENTIFICADOR PARENTESIS_C
                   ;
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
        vaciar_pila(&pilaInit);
    }

   printf("\nFLEX finalizo la lectura del archivo %s \n", argv[1]);
     fclose(yyin);
   return 0;
}

int yyerror(void)
     {
       printf("Error Sintactico %s\n",yytext);
         exit (1);
     }
