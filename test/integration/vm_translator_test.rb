# typed: true
require "test_helper"

class VMTranslatorIntegrationTest < Minitest::Test
  Dir.glob("*.vm", base: "examples").each do |file_name|
    base_name = File.basename(file_name, ".*")
    test_name = "test_integration_#{base_name}"

    define_method(test_name) do
      T.bind(self, VMTranslatorIntegrationTest)
      assembly_code = `bin/vm-translator examples/#{file_name}`
      expected = File.read("test/fixtures/#{base_name}.asm")
      assert_equal(expected, assembly_code)
    end
  end
end
