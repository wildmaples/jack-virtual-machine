class VMTranslator
  def initialize(input_file)
    @input_file = input_file
  end

  def translate
    parser = Parser.new(@input_file)

    while parser.has_more_commands?
      parser.advance
      case parser.command_type
      when :C_PUSH
        # Do something
      end
    end
  end
end
