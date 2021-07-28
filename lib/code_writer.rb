class CodeWriter
  def initialize(out)
    @out = out
    @label_counter = 0
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
        @EQUAL#{@label_counter}
        D;JEQ

        @SP
        A=M-1
        M=0
        @END#{@label_counter}
        0;JMP

        (EQUAL#{@label_counter})
        @SP
        A=M-1
        M=-1
        (END#{@label_counter})
      EOF
      @label_counter += 1
    elsif command == "lt"
      @out.puts <<~EOF
        AM=M-1
        D=M
        A=A-1

        D=M-D
        @LESSTHAN#{@label_counter}
        D;JLT

        @SP
        A=M-1
        M=0
        @END#{@label_counter}
        0;JMP

        (LESSTHAN#{@label_counter})
        @SP
        A=M-1
        M=-1
        (END#{@label_counter})
      EOF
      @label_counter += 1
    end
  end

  def close
    @out.close
  end
end
