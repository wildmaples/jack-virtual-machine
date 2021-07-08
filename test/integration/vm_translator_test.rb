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
end
