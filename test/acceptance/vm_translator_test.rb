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
      cpu_emulator_exit_status = nil
      _cpu_emulator_output, cpu_emulator_error = capture_subprocess_io do
        cpu_emulator_exit_status = system(CPU_EMULATOR_PATH, test_script_path)
      end

      # generate a diff between SimpleAdd.cmp and SimpleAdd.out
      unless cpu_emulator_exit_status
        expected_result, actual_result = ["cmp", "out"].map do |extension|
          File.read(File.join(temporary_directory, "SimpleAdd.#{extension}"))
        end
        cpu_emulator_error << diff(expected_result, actual_result)
      end

      # check that the exit status was `true` (i.e. success)
      assert(cpu_emulator_exit_status, cpu_emulator_error)
    end
  end
end
