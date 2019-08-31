class Calculator
  def initialize(args)
    @args = args.delete(' ')
    @result_numerator = 0
    @result_denominator = 0
  end

  attr_accessor :res, :result_numerator, :result_denominator, :num1, :num2
  def input_validation?
    if @args.match(/[^0-9^_*+-\/]/).nil? && !['+', '*', '/'].include?(@args[0]) && !['+', '*', '/', '-'].include?(@args[-1])
      true
    else
      puts "Invalid input format"
      false
    end
  end

  def format_identifier
    expr = [/[-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*/]
    numbers = []
    args = @args
    numbers << args.slice!(expr[0]) while args.match expr[0]

    while numbers.size < 2 && args.match(expr[1])
      numbers << args.slice!(expr[1])
    end

    while numbers.size < 2 && args.match(expr[2])
      numbers << args.slice!(expr[2])
    end
    [numbers, args]
  end

  def construct_operand?
    numbers, operator = format_identifier
    if operator.size > 1 || !['', '+', '-', '*', '/'].include?(operator) || numbers.size != 2
      puts('Invalid input format')
      false
    else
      @num1 = FractionNumber.new(numbers[0])
      @num2 = FractionNumber.new(numbers[1])
      @operator = operator.empty? ? '+' : operator
      true
    end
  end

  def improper_numerator_format(num, lcm)
    improper_numerator = num.improper_numerator * (lcm / num.improper_denominator)
    num.negative ? improper_numerator * -1 : improper_numerator
  end

  def plus
    @result_denominator = lcm = @num1.improper_denominator.lcm @num2.improper_denominator
    @result_numerator = improper_numerator_format(@num1, lcm) + improper_numerator_format(@num2, lcm)
  end

  def minus
    @result_denominator = lcm = @num1.improper_denominator.lcm(@num2.improper_denominator)
    @result_numerator = improper_numerator_format(@num1, lcm) - improper_numerator_format(@num2, lcm)
  end

  def multiply
    @result_numerator = @num1.improper_numerator * @num2.improper_numerator * ((@num1.negative == @num2.negative) ? 1 : -1)
    @result_denominator = @num1.improper_denominator * @num2.improper_denominator
  end

  def divide
    @result_numerator = @num1.improper_numerator * @num2.improper_denominator * ((@num1.negative == @num2.negative) ? 1 : -1)
    @result_denominator = @num1.improper_denominator * @num2.improper_numerator
  end

  def format_result
    @res = FractionNumber.new('')
    @res.negative = result_numerator < 0
    gcd = result_numerator.gcd(result_denominator)
    numerator = result_numerator.abs / gcd
    denominator = result_denominator / gcd
    integer = numerator / denominator
    numerator = numerator % denominator
    @res.number = integer
    @res.numerator = numerator
    @res.denominator = denominator
    @res
  end

  def print_result
    number = ""
    if @res.number != 0
      number = @res.negative ? "-#{@res.number}" : @res.number.to_s
      number += "_" if @res.numerator != 0
    else
      number = "0" if @res.numerator == 0
    end

    numerator = ""
    if @res.numerator != 0
      numerator = @res.negative && @res.number == 0 ? "-#{@res.numerator}/#{@res.denominator}" : "#{@res.numerator}/#{@res.denominator}"
    end
    number + numerator
  end

  def calculate
    if input_validation? && construct_operand?
      case @operator
      when '+'
        plus
      when '-'
        minus
      when '*'
        multiply
      else
        divide
      end
      format_result
      print_result
    end
  end

  class FractionNumber
    def initialize(args)
      unless args.empty?
        @negative = args[0] == '-'
        numbers = format_identifier(args)
        @number, @numerator, @denominator = numbers #args.split(/[\_,\/]/).map(&:to_i).map(&:abs)
        @improper_numerator = denominator * number + numerator
        @improper_denominator = denominator
      end
    end
    attr_accessor :number, :numerator, :denominator, :improper_numerator, :negative, :improper_denominator

    def format_identifier(args)
      # Three Regex to match input patterns
      expr = [/[-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*/]
      if args.match(expr[0])
        args.split(/[\_,\/]/).map(&:to_i).map(&:abs)
      elsif args.match(expr[1])
        [0] + args.split(/[\_,\/]/).map(&:to_i).map(&:abs)
      else
        [args.to_i.abs, 0, 1]
      end
    end
  end
end

# Regex Notes:
# [-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*
