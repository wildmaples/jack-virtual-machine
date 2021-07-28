require "test_helper"
require "fileutils"
require "tmpdir"

class VMTranslatorAcceptanceTest < Minitest::Test
  CPU_EMULATOR_PATH = ENV["CPU_EMULATOR"]

  def test_acceptance_test_simple_add
    skip "can’t find CPU emulator, please set CPU_EMULATOR" unless CPU_EMULATOR_PATH

    # make a temporary directory
    Dir.mktmpdir do |temporary_directory|
      # copy the SimpleAdd.tst and SimpleAdd.cmp files into it
      FileUtils.copy(
        [
          "test/fixtures/SimpleAdd.tst",
          "test/fixtures/SimpleAdd.cmp"
        ],
        temporary_directory
      )

      # translate SimpleAdd.vm and write the result into SimpleAdd.asm
      assembly_code = `bin/vm-translator examples/SimpleAdd.vm`
      assembly_code_path = File.join(temporary_directory, "SimpleAdd.asm")
      File.write(assembly_code_path, assembly_code)

      # run SimpleAdd.tst in the CPU emulator and remember its exit status
      test_script_path = File.join(temporary_directory, "SimpleAdd.tst")
      cpu_emulator_exit_status = system(CPU_EMULATOR_PATH, test_script_path)

      # check that the exit status was `true` (i.e. success)
      assert(cpu_emulator_exit_status)
    end
  end
end
