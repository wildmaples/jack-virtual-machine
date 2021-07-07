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
end
