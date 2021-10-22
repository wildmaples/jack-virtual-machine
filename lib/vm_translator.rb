require_relative 'code_writer'
require_relative 'parser'
require 'stringio'

class VMTranslator
  def initialize(out)
    @out = out
    @code_writer = CodeWriter.new(out)
  end

  attr_reader :out, :code_writer

  def translate(input_file)
    parser = Parser.new(input_file)
    file_name = File.basename(input_file.path, ".vm")

    code_writer.set_file_name(file_name)
    while parser.has_more_commands?
      parser.advance
      case parser.command_type
      when :C_PUSH, :C_POP
        code_writer.write_push_pop(parser.command_type, parser.arg1, parser.arg2)
      when :C_LABEL
        code_writer.write_label(parser.arg1)
      when :C_IF
        code_writer.write_if(parser.arg1)
      when :C_GOTO
        code_writer.write_goto(parser.arg1)
      when :C_ARITHMETIC
        code_writer.write_arithmetic(parser.arg1)
      when :C_FUNCTION
        code_writer.write_function(parser.arg1, parser.arg2)
      when :C_RETURN
        code_writer.write_return
      when :C_CALL
        code_writer.write_call(parser.arg1, parser.arg2)
      else
        warn("Unknown command type passed into VMTranslator")
      end
    end
  end

  def close
    code_writer.close
  end
end
