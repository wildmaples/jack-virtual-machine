class CodeWriter
  def initialize(out)
    @out = out
    @label_counter = 0
  end

  def set_file_name(file_name)
    @file_name = file_name
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

  def write_init
    @out.puts <<~EOF
      @256
      D=A
      @SP
      M=D
    EOF

    write_call("Sys.init", 0)
  end

  def write_label(label)
    @out.puts "($#{label})\n"
  end

  def write_goto(label)
    @out.puts <<~EOF
      @$#{label}
      0;JMP
    EOF
  end

  def write_if(label)
    @out.puts <<~EOF
      @SP
      AM=M-1
      D=M
      @$#{label}
      D;JNE
    EOF
  end

  def write_call(function_name, num_args)
    @out.puts <<~EOF
      @$return-address#{@label_counter}
      D=A
    EOF
    write_push_D_register

    ["LCL", "ARG", "THIS", "THAT"].each do |label|
      @out.puts <<~EOF
        @#{label}
        D=M
      EOF
      write_push_D_register
    end

    @out.puts <<~EOF
      @#{num_args + 5}
      D=A
      @SP
      D=M-D
      @ARG
      M=D
    EOF

    @out.puts <<~EOF
      @SP
      D=M
      @LCL
      M=D
    EOF

    write_goto(function_name)
    write_label("return-address#{@label_counter}")
    @label_counter += 1
  end

  def write_return
    @out.puts <<~EOF
      @LCL
      D=M
      @FRAME
      M=D
      @5
      A=D-A
      D=M
      @RET
      M=D
      @SP
      A=M-1
      D=M
      @ARG
      A=M
      M=D
      @ARG
      D=M+1
      @SP
      M=D
      @FRAME
      AM=M-1
      D=M
      @THAT
      M=D
      @FRAME
      AM=M-1
      D=M
      @THIS
      M=D
      @FRAME
      AM=M-1
      D=M
      @ARG
      M=D
      @FRAME
      AM=M-1
      D=M
      @LCL
      M=D
      @RET
      A=M
      0;JMP
    EOF
  end

  def write_function(function_name, num_locals)
    @out.puts "(#{function_name})\n"

    num_locals.times do
      write_push_pop(:C_PUSH, "constant", 0)
    end
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
    when "static"
      "@#{@file_name}.#{index}"
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
    when "static"
      "@#{@file_name}.#{index}\nD=M"
    end
  end

  def write_push_D_register
    @out.puts <<~EOF
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF
  end
end
