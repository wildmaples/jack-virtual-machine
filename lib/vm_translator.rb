require_relative 'code_writer'
require_relative 'parser'
require 'stringio'

class VMTranslator
  def initialize(input_file)
    @input_file = input_file
    @out = StringIO.new
    @code_writer = CodeWriter.new(@out)
  end

  def translate
    parser = Parser.new(@input_file)
    file_name = File.basename(@input_file.path, ".vm")

    @code_writer.set_file_name(file_name)
    while parser.has_more_commands?
      parser.advance
      case parser.command_type
      when :C_PUSH, :C_POP
        @code_writer.write_push_pop(parser.command_type, parser.arg1, parser.arg2)
      when :C_LABEL
        @code_writer.write_label(parser.arg1)
      when :C_IF
        @code_writer.write_if(parser.arg1)
      when :C_GOTO
        @code_writer.write_goto(parser.arg1)
      when :C_ARITHMETIC
        @code_writer.write_arithmetic(parser.arg1)
      else
        warn("Unknown command type passed into VMTranslator")
      end
    end

    @code_writer.close
    @out.string
  end
end
