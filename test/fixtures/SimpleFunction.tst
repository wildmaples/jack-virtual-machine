// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/08/FunctionCalls/SimpleFunction/SimpleFunction.tst

load SimpleFunction.asm,
output-file SimpleFunction.out,
compare-to SimpleFunction.cmp,
output-list RAM[0]%D1.6.1 RAM[1]%D1.6.1 RAM[2]%D1.6.1
            RAM[3]%D1.6.1 RAM[4]%D1.6.1 RAM[310]%D1.6.1;

set RAM[0] 317, // SP
set RAM[1] 317, // LCL
set RAM[2] 310, // ARG
set RAM[3] 3000, // THIS
set RAM[4] 4000, // THAT
set RAM[310] 1234, // arg 0
set RAM[311] 37, // arg 1
set RAM[312] 1000, // return
set RAM[313] 305, // saved lcl
set RAM[314] 300, // saved arg
set RAM[315] 3010, // saved this
set RAM[316] 4010, // saved that

repeat 300 {
  ticktock;
}

output;
