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

    while parser.has_more_commands?
      parser.advance
      case parser.command_type
      when :C_PUSH
        @code_writer.write_push_pop(:C_PUSH, parser.arg1, parser.arg2)
      when :C_ARITHMETIC
        @code_writer.write_arithmetic(parser.arg1)
      end
    end

    @code_writer.close
    @out.string
  end
end
