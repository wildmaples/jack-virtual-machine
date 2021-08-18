require "test_helper"

class VMTranslatorIntegrationTest < Minitest::Test
  def test_integration_test
    assembly_code = `bin/vm-translator examples/Push.vm`
    expected = File.read("test/fixtures/Push.asm")
    assert_equal(expected, assembly_code)
  end

  def test_integration_test_simple_add
    assembly_code = `bin/vm-translator examples/SimpleAdd.vm`
    expected = File.read("test/fixtures/SimpleAdd.asm")
    assert_equal(expected, assembly_code)
  end

  def test_integration_test_simple_eq
    assembly_code = `bin/vm-translator examples/SimpleEq.vm`
    expected = File.read("test/fixtures/SimpleEq.asm")
    assert_equal(expected, assembly_code)
  end

  def test_integration_test_stack_test
    assembly_code = `bin/vm-translator examples/StackTest.vm`
    expected = File.read("test/fixtures/StackTest.asm")
    assert_equal(expected, assembly_code)
  end

  def test_integration_test_basic_test
    assembly_code = `bin/vm-translator examples/BasicTest.vm`
    expected = File.read("test/fixtures/BasicTest.asm")
    assert_equal(expected, assembly_code)
  end
end
