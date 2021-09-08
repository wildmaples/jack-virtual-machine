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
      @SP
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
      @SP
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
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE0
      D;JEQ

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (IFTRUE0)
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
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE0
      D;JEQ

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (IFTRUE0)
      @SP
      A=M-1
      M=-1
      (END0)
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE1
      D;JEQ

      @SP
      A=M-1
      M=0
      @END1
      0;JMP

      (IFTRUE1)
      @SP
      A=M-1
      M=-1
      (END1)
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_lt
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("lt")
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE0
      D;JLT

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (IFTRUE0)
      @SP
      A=M-1
      M=-1
      (END0)
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_lt_twice
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("lt")
    code_writer.write_arithmetic("lt")
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE0
      D;JLT

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (IFTRUE0)
      @SP
      A=M-1
      M=-1
      (END0)
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE1
      D;JLT

      @SP
      A=M-1
      M=0
      @END1
      0;JMP

      (IFTRUE1)
      @SP
      A=M-1
      M=-1
      (END1)
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_gt
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("gt")
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      A=A-1

      D=M-D
      @IFTRUE0
      D;JGT

      @SP
      A=M-1
      M=0
      @END0
      0;JMP

      (IFTRUE0)
      @SP
      A=M-1
      M=-1
      (END0)
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_neg
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("neg")
    expected = <<~EOF
      @SP
      A=M-1
      M=-M
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_and
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("and")
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      A=A-1
      M=M&D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_or
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("or")
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      A=A-1
      M=M|D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_arithmetic_not
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_arithmetic("not")
    expected = <<~EOF
      @SP
      A=M-1
      M=!M
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_POP_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_POP, "local", 123)
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      @R13
      M=D
      @123
      D=A
      @LCL
      A=M+D
      D=A
      @R14
      M=D
      @R13
      D=M
      @R14
      A=M
      M=D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_POP_argument_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_POP, "argument", 123)
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      @R13
      M=D
      @123
      D=A
      @ARG
      A=M+D
      D=A
      @R14
      M=D
      @R13
      D=M
      @R14
      A=M
      M=D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_POP_temp_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_POP, "temp", 6)
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      @R13
      M=D
      @11
      D=A
      @R14
      M=D
      @R13
      D=M
      @R14
      A=M
      M=D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_another_C_POP_temp_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_POP, "temp", 1)
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      @R13
      M=D
      @6
      D=A
      @R14
      M=D
      @R13
      D=M
      @R14
      A=M
      M=D
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_PUSH_local
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_PUSH, "local", 0)
    expected = <<~EOF
      @0
      D=A
      @LCL
      A=M+D
      D=M
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF

    assert_equal(expected, output.string)
  end

  def test_write_push_pop_writes_C_POP_pointer_0_to_output
    output = StringIO.new
    code_writer = CodeWriter.new(output)
    code_writer.write_push_pop(:C_POP, "pointer", 0)
    expected = <<~EOF
      @SP
      AM=M-1
      D=M
      @R13
      M=D
      @3
      D=A
      @R14
      M=D
      @R13
      D=M
      @R14
      A=M
      M=D
    EOF

    assert_equal(expected, output.string)
  end
end
