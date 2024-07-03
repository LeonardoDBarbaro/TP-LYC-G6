include macros2.asm
include numbers.asm
.MODEL LARGE
.386
stack 200h

.DATA
@aux                           DW ?                               
@pivot                         DW ?                               
_1                             DD ?
_10                            DW ? 10                            
_11                            DW ? 11                            
_120                           DW ? 120                           
_2                             DW ? 2                             
_20                            DW ? 20                            
_3                             DW ? 3                             
_30                            DW ? 30                            
_4                             DD ?
_40                            DW ? 40                            
_50                            DD ?
_a1 mayor b1 o c1 mayor b1     DB 'a1 mayor b1 o c1 mayor b1', '$'
_a1 mayor b1 y c1 mayor b1     DB 'a1 mayor b1 y c1 mayor b1', '$'
_a1 no es mas grande que b1    DB 'a1 no es mas grande que b1', '$'
_segundo Brasil                DB 'segundo Brasil', '$'
a1                             DB 50 DUP (?)
b1                             DB 50 DUP (?)
c1                             DB 50 DUP (?)
cte1                           DW ?                               
cte2                           DW ?                               
id1                            DW ?                               
id2                            DW ?                               
p1                             DD ?
p2                             DD ?
p3                             DD ?
p4                             DD ?
reemplazar                     DW ?                               
variable1                      DW ?                               
variable2                      DW ?                               
variable3                      DW ?                               
x                              DW ?                               

.CODE
MAIN PROC
FILD _20
FISTP id1
FILD _10
FILD _11
FADD
FISTP variable1
FILD _10
FILD _11
FILD _3
FMUL
FADD
FILD _2
FADD
FILD variable1
FSUB
FISTP variable2
FILD _40
FISTP variable3
mov dx,OFFSET segundo Brasil
mov ah,9
mov dx,OFFSET variable1
mov ah,9
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq40
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq31
FILD _30
FISTP variable3
Etiq31:
FILD id1
FILD id2
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq38
FILD _40
FISTP variable2
Etiq38:
JMP Etiq43
Etiq40:
FILD a1
FISTP c1
Etiq43:
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq50
FILD _30
FISTP variable2
Etiq50:
Etiq51:
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq59
FILD b1
FISTP a1
JMP Etiq51
Etiq59:
FILD _120
FISTP variable1
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq69
FILD variable2
FISTP variable1
JMP Etiq72
Etiq69:
FILD variable3
FISTP variable1
Etiq72:
MOV SI, OFFSET p1
MOV DI, OFFSET p2
MOV CX, 0 

CALL CountLength
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq87
FILD c1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq86
MOV SI, OFFSET _a1 mayor b1 y c1 mayor b1
MOV DI, OFFSET p3
MOV CX, 0 

CALL CountLength
mov dx,OFFSET p3
mov ah,9
Etiq86:
Etiq87:
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq96
FILD c1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JLE Etiq98
Etiq96:
mov dx,OFFSET a1 mayor b1 o c1 mayor b1
mov ah,9
Etiq98:
FILD variable1
FILD variable3
FILD _3
FMUL
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq108
FILD a1
FISTP b1
JMP Etiq111
Etiq108:
FILD variable2
FISTP variable1
Etiq111:
FILD a1
FILD b1
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq119
MOV SI, OFFSET _a1 no es mas grande que b1
MOV DI, OFFSET p4
MOV CX, 0 

CALL CountLength
mov dx,OFFSET p4
mov ah,9
Etiq119:
FILD id2
FILD cte1
FMUL
FILD cte2
FADD
FISTP id1
Etiq126:
FILD x
FILD _11
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JG Etiq136
FILD _3
FILD x
FADD
FISTP x
JMP Etiq126
Etiq136:
FISTP @pivot
FISTP @aux
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JEQ Etiq155
FISTP @aux
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JEQ Etiq155
FISTP @aux
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JEQ Etiq155
FISTP @aux
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JEQ Etiq155
FISTP @aux
FXCH
FCOM
FSTSW AX
SAHF
FFREE
JEQ Etiq155
mov dx,OFFSET numero no encontrado
mov ah,9
JMP Etiq157
Etiq155:
FISTP reemplazar
Etiq157:
mov ah, 4Ch
mov al, 0
int 21h;
CountLength:
MOV AL, [SI]
INC SI
CMP AL, 0
JE EndCount
INC CX
JMP CountLength

EndCount:
RET

MAIN ENDP
END MAIN
