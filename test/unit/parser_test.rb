require "test_helper"
require "parser"

class ParserTest < Minitest::Test
  def test_that_has_more_commands_returns_false_when_no_commands
    input_file = StringIO.new
    parser = Parser.new(input_file)
    refute(parser.has_more_commands?)
  end

  def test_that_has_more_commands_returns_true_when_commands_available
    input_file = StringIO.new("push constant 17")
    parser = Parser.new(input_file)
    assert(parser.has_more_commands?)
  end

  def test_advance_lines_twice
    input_file = StringIO.new("push constant 17\npush constant 18")
    parser = Parser.new(input_file)
    assert(parser.has_more_commands?)
    parser.advance
    parser.advance
    refute(parser.has_more_commands?)
  end

  def test_comments_in_input_file
    input_file = StringIO.new("// comment\npush constant 17")
    parser = Parser.new(input_file)

    assert(parser.has_more_commands?)
    parser.advance

    # assert_equal("push constant 17", parser.comp)
    # assert_equal(:C_COMMAND, parser.command_type)
    refute(parser.has_more_commands?)
  end

  def test_inline_comments_in_input_file
    input_file = StringIO.new("push constant 17 // in-line comment")
    parser = Parser.new(input_file)

    assert(parser.has_more_commands?)
    parser.advance

    # assert_equal("1234", parser.symbol)
    # assert_equal(:A_COMMAND, parser.command_type)
    refute(parser.has_more_commands?)
  end

  def test_blank_lines_in_input_file
    input_file = StringIO.new("\n\npush constant 17\n\n")
    parser = Parser.new(input_file)

    assert(parser.has_more_commands?)
    parser.advance

    # assert_equal("D&M", parser.comp)
    # assert_equal(:C_COMMAND, parser.command_type)
    refute(parser.has_more_commands?)
  end
end
