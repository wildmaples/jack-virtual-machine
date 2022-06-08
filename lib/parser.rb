# typed: true
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

  NON_ARITHMETIC_COMMAND_TYPES = {
    'push' => :C_PUSH,
    'pop' => :C_POP,
    'label' => :C_LABEL,
    'if-goto' => :C_IF,
    'goto' => :C_GOTO,
    'function' => :C_FUNCTION,
    'return' => :C_RETURN,
    'call' => :C_CALL
  }

  def command_type
    raw_command = @command.split[0]
    NON_ARITHMETIC_COMMAND_TYPES.fetch(raw_command, :C_ARITHMETIC)
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
