require "test_helper"

class VMTranslatorIntegrationTest < Minitest::Test
  def test_integration_test
    assembly_code = `bin/vm-translator examples/Push.vm`
    expected = <<~EOF
      @17
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
    EOF

    assert_equal(expected, assembly_code)
  end

  def test_integration_test_simple_add
    assembly_code = `bin/vm-translator examples/SimpleAdd.vm`
    expected = <<~EOF
      @7
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
      @8
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
      AM=M-1
      D=M
      A=A-1
      M=M+D
    EOF

    assert_equal(expected, assembly_code)
  end

  def test_integration_test_simple_eq
    assembly_code = `bin/vm-translator examples/SimpleEq.vm`
    expected = <<~EOF
      @8
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
      @9
      D=A
      @SP
      A=M
      M=D
      @SP
      M=M+1
      AM=M-1
      D=M
      A=A-1
      
      D=M-D
      @EQUAL
      D;JEQ
      
      @SP
      A=M-1
      M=0
      @END
      0;JMP
      
      (EQUAL)
      @SP
      A=M-1
      M=-1
      (END)
    EOF

    assert_equal(expected, assembly_code)
  end
end
