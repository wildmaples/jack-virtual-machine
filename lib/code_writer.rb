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

  def close
    @out.close
  end
end
