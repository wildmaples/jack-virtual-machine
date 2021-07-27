class CodeWriter
  def initialize(out)
    @out = out 
  end

  def write_push_pop(command, segment, index)
    @out.puts <<~EOF
      @#{index}
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF
  end

  def write_arithmetic(command)
    if command == "add" or command == "sub" 
      operation = command == "add" ? "+" : "-"
      @out.puts <<~EOF
        AM=M-1
        D=M
        A=A-1
        M=M#{operation}D
      EOF
    elsif command == "eq"
      @out.puts <<~EOF
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
      EOF
    end
  end

  def close
    @out.close
  end
end
