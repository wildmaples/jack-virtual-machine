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

  COMMAND_TO_OPERATION_HASH = {
    "add" => "+",
    "sub" => "-",
    "and" => "&",
    "or" => "|"
  }

  def write_arithmetic(command)
    if command == "neg"
      @out.puts <<~EOF
        A=M-1
        M=-M
      EOF
    elsif COMMAND_TO_OPERATION_HASH.key?(command)
      @out.puts <<~EOF
        AM=M-1
        D=M
        A=A-1
        M=M#{COMMAND_TO_OPERATION_HASH[command]}D
      EOF
    elsif command == "eq" or command == "lt" or command == "gt"
      @out.puts <<~EOF
        AM=M-1
        D=M
        A=A-1

        D=M-D
        @IFTRUE#{@label_counter}
        D;J#{command.upcase}

        @SP
        A=M-1
        M=0
        @END#{@label_counter}
        0;JMP

        (IFTRUE#{@label_counter})
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
