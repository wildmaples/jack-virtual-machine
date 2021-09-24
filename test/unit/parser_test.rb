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

    assert_equal(:C_PUSH, parser.command_type)
    assert_equal("constant", parser.arg1)
    assert_equal(17, parser.arg2)
    refute(parser.has_more_commands?)
  end

  def test_inline_comments_in_input_file
    input_file = StringIO.new("push constant 17 // in-line comment")
    parser = Parser.new(input_file)

    assert(parser.has_more_commands?)
    parser.advance

    assert_equal(:C_PUSH, parser.command_type)
    assert_equal("constant", parser.arg1)
    assert_equal(17, parser.arg2)
    refute(parser.has_more_commands?)
  end

  def test_blank_lines_in_input_file
    input_file = StringIO.new("\n\npush constant 17\n\n")
    parser = Parser.new(input_file)

    assert(parser.has_more_commands?)
    parser.advance

    assert_equal(:C_PUSH, parser.command_type)
    assert_equal("constant", parser.arg1)
    assert_equal(17, parser.arg2)
    refute(parser.has_more_commands?)
  end

  def test_command_type_returns_push_command
    input_file = StringIO.new("push constant 17")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(:C_PUSH, parser.command_type)
  end

  def test_command_type_returns_arithmetic_command
    input_file = StringIO.new("lt")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(:C_ARITHMETIC, parser.command_type)
  end

  def test_arg1_for_arithmetic_command_less_than
    input_file = StringIO.new("lt")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal("lt", parser.arg1)
  end

  def test_arg1_for_arithmetic_command_add
    input_file = StringIO.new("add")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal("add", parser.arg1)
  end

  def test_arg1_for_push_command
    input_file = StringIO.new("push constant 17")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal("constant", parser.arg1)
  end

  def test_arg2_for_push_command
    input_file = StringIO.new("push constant 17")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(17, parser.arg2)
  end

  def test_command_type_returns_pop_command
    input_file = StringIO.new("pop local 0")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(:C_POP, parser.command_type)
  end

  def test_arg1_for_pop_command
    input_file = StringIO.new("pop local 0")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal("local", parser.arg1)
  end

  def test_arg2_for_pop_command
    input_file = StringIO.new("pop local 0")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(0, parser.arg2)
  end

  def test_command_type_returns_label_command_and_arg1
    input_file = StringIO.new("label LOOP_START")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(:C_LABEL, parser.command_type)
    assert_equal("LOOP_START", parser.arg1)
  end

  def test_command_type_returns_if_command_and_arg1
    input_file = StringIO.new("if-goto LOOP_START")
    parser = Parser.new(input_file)

    parser.advance
    assert_equal(:C_IF, parser.command_type)
    assert_equal("LOOP_START", parser.arg1)
  end
end
