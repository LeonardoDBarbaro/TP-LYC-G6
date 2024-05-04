%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <string.h>
int yyerror(void);
int fn_verificar_rango(char* ptr);

#include "y.tab.h"
FILE  *yyin;
char *yyltext;



%}

%option noyywrap  
%option yylineno

/*  SECCION TOKENS  */
DIGITO          [0-9]
LETRA           [a-zA-Z]
ESPACIO         [" "]
COMENTARIO_A    "*""-"
COMENTARIO_C    "-""*"
COMENTARIO      {COMENTARIO_A}[^-*]*{COMENTARIO_C}
GUIONES         [-_]
CHAR_COMA       [","]
CHAR_PUNTO      ["."]
CHAR_PUNTOYCOMA [";"]
CHAR_DOSPUNTOS  [":"]

IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO}|{GUIONES}{1,5})*
CONST_INTEGER   {DIGITO}{1,5}
CONST_FLOAT     {DIGITO}{0,8}*{CHAR_PUNTO}{DIGITO}{1,8}
/*La regex de abajo considera string a todo lo que este dentro de comillas dobles excepto el caracter de fin de linea y la propia comilla doble.*/
CONST_CADENA    \"[^\n"]*\"

/* operadores logicos y operadores aritmeticos basicos */
OP_SUMA         ["+"]
OP_RESTA        ["-"]
OP_MULT         ["*"]
OP_DIV          ["/"]
OP_IGUAL        ["="]
OP_MAYOR        [">"]
OP_MENOR        ["<"]
OP_MAYORIGUAL   ">="
OP_MENORIGUAL   "<="
OP_COMP_IGUAL   "=="
OP_NEGACION     "!"
OP_DISTINTO     "!="
/*Tiene doble funcionalidad, definir un tipo de datos o asignar un valor.*/
OP_DOSPUNTOS    [":"]

/* caracteres de apertura, cierre y fin de linea*/
LLAVE_A         ["{"]
LLAVE_C         ["}"]
PARENTESIS_A    ["("]
PARENTESIS_C    [")"]
FIN_SENTENCIA   [";"]

/* palabras reservadas*/
IF              "if"|"IF"|"si"
ELSE            "else"|"ELSE"|"sino"
WHILE           "while"|"WHILE"|"mientras"
INIT            "init"|"INIT"
INTEGER         "INTEGER"|"integer"|"Integer"|"int"|"INT"|"Int"
FLOAT           "FLOAT"|"float"|"Float"
STRING           "STRING"|"string"|"String"
WRITE           "write"|"WRITE"|"escribir"|"ESCRIBIR"
READ            "read"|"READ"|"leer"|"LEER"
AND             "and"|"AND"
OR              "or"|"OR"
NOT             "not"|"NOT"
UNTILLOOP       "untilloop"|"UNTILLOOP"|"untilLoop"
BUSCOYREEMPLAZO     "buscoyreemplazo"|"BUSCOYREEMPLAZO"|"buscoYReemplazo"
%%

{OP_DOSPUNTOS}      {return OP_DOSPUNTOS;}
{FIN_SENTENCIA}     {return FIN_SENTENCIA;}
{CHAR_COMA}         {return CHAR_COMA;}
{CHAR_PUNTOYCOMA}   {return CHAR_PUNTOYCOMA;}
{CONST_INTEGER}     {fn_verificar_rango(yytext); return CONST_INTEGER;}
{CONST_FLOAT}       {return CONST_FLOAT;}
{CONST_CADENA}      {return CONST_CADENA;}
{COMENTARIO}        {printf("%s",yytext);}
{OP_SUMA}           {return OP_SUMA;}
{OP_RESTA}          {return OP_RESTA;}
{OP_MULT}           {return OP_MULT;}
{OP_DIV}            {return OP_DIV;}
{OP_IGUAL}          {return OP_IGUAL;}
{OP_MAYOR}          {return OP_MAYOR;}
{OP_MENOR}          {return OP_MENOR;}
{OP_MAYORIGUAL}     {return OP_MAYORIGUAL;}
{OP_MENORIGUAL}     {return OP_MENORIGUAL;}
{OP_COMP_IGUAL}     {return OP_COMP_IGUAL;}
{OP_NEGACION}       {return OP_NEGACION;}
{OP_DISTINTO}       {return OP_DISTINTO;}
{OP_DOSPUNTOS}      {return OP_DOSPUNTOS;}
{AND}               {return AND;}
{OR}                {return OR;}
{NOT}               {return NOT;}
{UNTILLOOP}         {return UNTILLOOP;}
{BUSCOYREEMPLAZO}   {return BUSCOYREEMPLAZO;}


{LLAVE_A}           { return LLAVE_A;}
{LLAVE_C}           {return LLAVE_C;}
{PARENTESIS_A}      {return PARENTESIS_A;}
{PARENTESIS_C}      {return PARENTESIS_C;}

{IF}                {return IF;}
{ELSE}              {return ELSE;}
{WHILE}             {return WHILE;}
{INTEGER}           {return INTEGER;}
{FLOAT}             {return FLOAT;}
{STRING}             {return STRING;}
{WRITE}             {return WRITE;}
{READ}              {return READ;}
{INIT}            {return INIT;}
{INTEGER}           {return INTEGER;}

{IDENTIFICADOR}     { yylval.strVal = strdup(yytext); return IDENTIFICADOR;}

"\n"
"\t"
" "
.       //yyerror(); /*si llego aca es porque no encontro ninguna regex o token que matchee con el caracter leido por flex.*/
%%


/*
int yyerror(void){
    printf("\nError lexico: Caracter invalido: %s, saliendo...\n", yytext);
    exit(1);
}
*/


/*-32768 a 32767*/
int fn_verificar_rango(char*ptr){
    int value = atoi(ptr);
    if( value < -32768 || value > 32767){
        printf("Error: varieble fuera de rango: %s", yytext);
        return yyerror();
    }

    return 0;
}

/*
int main(int argc, char *argv[]){
    if( (yyin = fopen(argv[1], "rt")) == NULL){
        printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
        return 1;
    }
    else{
        printf("\n El archivo %s se abrio correctamente\n", argv[1]);
        yylex();
    }

    printf("\nFLEX finalizo la lectura del archivo %s \n", argv[1]);
    fclose(yyin);
    return 0;
}
*/

