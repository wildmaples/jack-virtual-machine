class VMTranslator
  def initialize(input_file)
    @input_file = input_file
    @code_writer = CodeWriter.new(STDOUT)
  end

  def translate
    parser = Parser.new(@input_file)

    while parser.has_more_commands?
      parser.advance
      case parser.command_type
      when :C_PUSH
        @code_writer.write_push_pop(:C_PUSH, parser.arg1, parser.arg2)
      end
    end

    @code_writer.close
  end
end
