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
end
