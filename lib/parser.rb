class Parser
  def initialize(input_file)
    @lines = remove_non_commands(input_file.readlines)
  end

  def remove_non_commands(lines)
    lines
      .map { |line| line[0...line.index("//")] }
      .map(&:strip)
      .reject(&:empty?)
  end

  def has_more_commands?
    !@lines.empty?
  end

  def advance
    @command = @lines.shift
  end

  NON_ARITHMETIC_COMMANDS = ["push", "pop", "label", "if-goto", "goto"]

  def command_type
    raw_command = @command.split[0]

    case raw_command
    when *NON_ARITHMETIC_COMMANDS
      "C_#{raw_command.split("-")[0].upcase}".to_sym
    else
      :C_ARITHMETIC
    end
  end

  def arg1
    if command_type == :C_ARITHMETIC
      @command
    else
      @command.split[1]
    end
  end

  def arg2
    Integer(@command.split[2])
  end
end
