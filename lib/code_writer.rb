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
    case command
    when :C_POP
      @out.puts <<~EOF
        @SP
        AM=M-1
        D=M
        @R13
        M=D
        #{get_final_memory_address_for_pop(segment, index).chomp}
        D=A
        @R14
        M=D
        @R13
        D=M
        @R14
        A=M
        M=D
      EOF

    when :C_PUSH
      @out.puts <<~EOF
        #{get_value_for_push(segment, index).chomp}
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

  private

  def get_final_memory_address_for_pop(segment, index)
    case segment
    when "temp", "pointer"
      starting_index = segment == "temp" ? 5 : 3
      "@#{starting_index + index}"
    when *SEGMENT_TO_SYMBOL_HASH.keys
       <<~EOF
        @#{index}
        D=A
        @#{SEGMENT_TO_SYMBOL_HASH[segment]}
        A=M+D
      EOF
    end
  end

  def get_value_for_push(segment, index)
    case segment
    when "temp", "pointer"
      starting_index = segment == "temp" ? 5 : 3
      "@#{starting_index + index}\nD=M"
    when *SEGMENT_TO_SYMBOL_HASH.keys
      <<~EOF
        @#{index}
        D=A
        @#{SEGMENT_TO_SYMBOL_HASH[segment]}
        A=M+D
        D=M
      EOF
    else
      "@#{index}\nD=A"
    end
  end
end
