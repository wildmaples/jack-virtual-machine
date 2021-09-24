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

  def command_type
    if @command.start_with?("push")
      :C_PUSH
    elsif @command.start_with?("pop")
      :C_POP
    elsif @command.start_with?("label")
      :C_LABEL
    else
      :C_ARITHMETIC
    end
  end

  def arg1
    if [:C_PUSH, :C_POP, :C_LABEL].include?(command_type)
      @command.split[1]
    else
      @command
    end
  end

  def arg2
    Integer(@command.split[2])
  end
end
