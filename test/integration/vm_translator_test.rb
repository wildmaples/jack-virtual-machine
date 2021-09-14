require "test_helper"

class VMTranslatorIntegrationTest < Minitest::Test
  Dir.glob("examples/**").each do |file_path|
    file_name = /examples\/(.*).vm/.match(file_path)[1]
    test_name = "test_integration_#{file_name}"

    define_method(test_name) do
      assembly_code = `bin/vm-translator #{file_path}`
      expected = File.read("test/fixtures/#{file_name}.asm")
      assert_equal(expected, assembly_code)
    end
  end
end
