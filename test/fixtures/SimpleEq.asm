@8
D=A
@SP
A=M
M=D
@SP
M=M+1
@9
D=A
@SP
A=M
M=D
@SP
M=M+1
AM=M-1
D=M
A=A-1

D=M-D
@EQUAL
D;JEQ

@SP
A=M-1
M=0
@END
0;JMP

(EQUAL)
@SP
A=M-1
M=-1
(END)
