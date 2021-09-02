class CodeWriter
  def initialize(out)
    @out = out
    @label_counter = 0
  end

  SEGMENT_TO_SYMBOL_HASH = {
    "argument" => "ARG",
    "local" => "LCL",
    "this" => "THIS",
    "that" => "THAT",
  }

  def write_push_pop(command, segment, index)
    if command == :C_POP
      if segment == "temp"
        final_memory_address = "@#{5+index}"
      else
        final_memory_address = <<~EOF
          @#{index}
          D=A
          @#{SEGMENT_TO_SYMBOL_HASH[segment]}
          A=M+D
        EOF
      end

      @out.puts <<~EOF
        @SP
        AM=M-1
        D=M
        @R13
        M=D
        #{final_memory_address.chomp}
        D=A
        @R14
        M=D
        @R13
        D=M
        @R14
        A=M
        M=D
      EOF

    else
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
  end

  COMMAND_TO_OPERATION_HASH = {
    "add" => "+",
    "sub" => "-",
    "and" => "&",
    "or" => "|"
  }

  def write_arithmetic(command)
    @out.puts <<~EOF
      @SP
    EOF

    if command == "neg" or command == "not"
      operation = command == "neg" ? "-" : "!"
      @out.puts <<~EOF
        A=M-1
        M=#{operation}M
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
