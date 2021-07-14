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
    operation = command == "add" ? "+" : "-"
    @out.puts <<~EOF
      AM=M-1
      D=M
      A=A-1
      M=M#{operation}D
    EOF
  end

  def close
    @out.close
  end
end
