require "test_helper"
require "fileutils"
require "tmpdir"

class VMTranslatorAcceptanceTest < Minitest::Test
  CPU_EMULATOR_PATH = ENV["CPU_EMULATOR"]

  Dir.glob("*.tst", base: "test/fixtures").each do |file_name|
    base_name = File.basename(file_name, ".*")
    test_name = "test_acceptance_#{base_name}"

    define_method(test_name) do
      skip "can’t find CPU emulator, please set CPU_EMULATOR" unless CPU_EMULATOR_PATH

      # make a temporary directory
      Dir.mktmpdir do |temporary_directory|
        # copy the .tst and .cmp files into it
        FileUtils.copy(
          [
            "test/fixtures/#{base_name}.tst",
            "test/fixtures/#{base_name}.cmp"
          ],
          temporary_directory
        )

        # translate .vm and write the result into .asm
        assembly_code = `bin/vm-translator examples/#{base_name}.vm`
        assembly_code_path = File.join(temporary_directory, "#{base_name}.asm")
        File.write(assembly_code_path, assembly_code)

        # run .tst in the CPU emulator and remember its exit status
        test_script_path = File.join(temporary_directory, "#{base_name}.tst")
        cpu_emulator_exit_status = nil
        _cpu_emulator_output, cpu_emulator_error = capture_subprocess_io do
          cpu_emulator_exit_status = system(CPU_EMULATOR_PATH, test_script_path)
        end

        # generate a diff between .cmp and .out
        unless cpu_emulator_exit_status
          expected_result, actual_result = ["cmp", "out"].map do |extension|
            File.read(File.join(temporary_directory, "#{base_name}.#{extension}"))
          end
          cpu_emulator_error << diff(expected_result, actual_result)
        end

        # check that the exit status was `true` (i.e. success)
        assert(cpu_emulator_exit_status, cpu_emulator_error)
      end
    end
  end
end
