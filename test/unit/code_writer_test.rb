require "test_helper"
require "code_writer"

class CodeWriterTest < Minitest::Test
  def test_write_push_pop_writes_C_PUSH_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_PUSH, "constant", 17)
    expected = <<~EOF
      @17
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_PUSH_to_output_999
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_PUSH, "constant", 999)
    expected = <<~EOF
      @999
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF

    assert_equal(expected, output.string)
  end

  def test_close_closes_io
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    refute(output.closed?)
    code_writer.close
    assert(output.closed?)
  end

  def test_write_arithmetic_add
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("add")
    expected = <<~EOF
      AM=M-1
      D=M
      A=A-1
      M=M+D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_sub
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("sub")
    expected = <<~EOF
      AM=M-1
      D=M
      A=A-1
      M=M-D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_eq
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("eq")
    expected = <<~EOF
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @EQUAL0
      D;JEQ

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (EQUAL0)
      @SP
      A=M-1
      M=-1
      (END0)
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_eq_twice
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("eq")
    code_writer.write_arithmetic("eq")
    expected = <<~EOF
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @EQUAL0
      D;JEQ

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (EQUAL0)
      @SP
      A=M-1
      M=-1
      (END0)
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @EQUAL1
      D;JEQ

      @SP
      A=M-1
      M=0
      @END1
      0;JMP

      (EQUAL1)
      @SP
      A=M-1
      M=-1
      (END1)
    EOF

    assert_equal(expected, output.string)
  end
end
