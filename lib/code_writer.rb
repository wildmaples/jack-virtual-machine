class CodeWriter
  def initialize(out)
    @out = out
    @label_counter = 0
  end

  DYNAMIC_SEGMENT_POINTER_ADDRESS = {
    "argument" => "ARG",
    "local" => "LCL",
    "this" => "THIS",
    "that" => "THAT",
  }

  STATIC_SEGMENT_BASE_ADDRESS = {
    "temp" => 5,
    "pointer" => 3,
    "static" => 16,
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
        #{get_address_for_pop(segment, index)}
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
        #{get_value_for_push(segment, index)}
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

  def get_address_for_pop(segment, index)
    case segment
    when *STATIC_SEGMENT_BASE_ADDRESS.keys
      "@#{STATIC_SEGMENT_BASE_ADDRESS[segment] + index}"
    when *DYNAMIC_SEGMENT_POINTER_ADDRESS.keys
      <<~EOF.chomp
        @#{index}
        D=A
        @#{DYNAMIC_SEGMENT_POINTER_ADDRESS[segment]}
        A=M+D
      EOF
    end
  end

  def get_value_for_push(segment, index)
    case segment
    when *STATIC_SEGMENT_BASE_ADDRESS.keys
      "@#{STATIC_SEGMENT_BASE_ADDRESS[segment] + index}\nD=M"
    when *DYNAMIC_SEGMENT_POINTER_ADDRESS.keys
      <<~EOF.chomp
        @#{index}
        D=A
        @#{DYNAMIC_SEGMENT_POINTER_ADDRESS[segment]}
        A=M+D
        D=M
      EOF
    when "constant"
      "@#{index}\nD=A"
    end
  end
end
