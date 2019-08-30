# Calculator class accept input string to process improper fraction calculator
#
class Calculator
  attr_accessor :res, :result_numerator, :result_denominator, :num1, :num2
  def initialize(str)
    str = str.delete(' ')
    @result_numerator = 0
    @result_denominator = 0
    numbers, operator = format_identifer(str)
    @num1 = FractionNumber.new(numbers[0])
    @num2 = FractionNumber.new(numbers[1])
    @operator = operator.empty? ? '+' : operator
  end

  def format_identifer(str)
    expr = [/[-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*/]
    numbers = []
    while str.match expr[0]
      numbers << str.slice!(expr[0])
    end

    while numbers.size < 2 && str.match(expr[1])
      numbers << str.slice!(expr[1])
    end

    while numbers.size < 2 && str.match(expr[2])
      numbers << str.slice!(expr[2])
    end
    [numbers, str]
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
    @result_numerator = @num1.improper_numerator * @num2.improper_numerator
    @result_denominator = @num1.improper_denominator * @num2.improper_denominator
  end

  def divide
    @result_numerator = @num1.improper_numerator * @num2.improper_denominator
    @result_denominator = @num1.improper_denominator * @num2.improper_numerator
  end

  def format_result
    gcd = result_numerator.gcd(result_denominator)
    numerator = result_numerator / gcd
    denominator = result_denominator / gcd
    integer = numerator / denominator
    numerator = numerator % denominator
    @res = FractionNumber.new("")
    @res.number = integer
    @res.numerator = numerator
    @res.denominator = denominator
    @res
  end

  def result
    number = @res.number != 0 ? "#{@res.number}" : ""
    numerator = @res.numerator != 0 ? "_#{@res.numerator}/" : ""
    denominator = @res.denominator > 1 ? "#{@res.denominator}" : ""
    number + numerator + denominator
  end

  def calculate
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
    result
  end

  class FractionNumber
    attr_accessor :number, :numerator, :denominator, :improper_numerator, :negative, :improper_denominator

    def initialize(str)
      unless str.empty?
        @negative = str[0] == '-' ? true : false
        numbers = format_identifer(str)
        @number, @numerator, @denominator = numbers #str.split(/[\_,\/]/).map(&:to_i).map(&:abs)
        @improper_numerator = denominator * number + numerator
        @improper_denominator = denominator
      end
    end

    def format_identifer(str)
      # Three Regex to match input patterns
      expr = [/[-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*\/[1-9][0-9]*/, /[-]?[1-9][0-9]*/]
      case
      when str.match(expr[0])
        str.split(/[\_,\/]/).map(&:to_i).map(&:abs)
      when str.match(expr[1])
        [0] + str.split(/[\_,\/]/).map(&:to_i).map(&:abs)
      else
        [str.to_i.abs, 0, 1]
      end
    end
  end
end

#================ Test case ================
test_case = ["  2 _ 3 /5  + 3_10/2 ", " - 2 _ 3 /5  + 3_10/2 ", "1/2*1/3", "1_3/5-1_1/5", "1_1/3*1_1/2", "1_2/3-1_1/3", "1/2+2/1", "2+3", "2+1/3", "1/3/1/2"]
test_case.each_with_index do |input, index|
  puts "Test case #{index + 1}:    " + input
  cal = Calculator.new(input)
  puts "Result: #{cal.calculate}\n\n"
end
#================ Test case ================


# Regex Notes:
# [-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*\_[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*\/[1-9][0-9]*
# [-]?[1-9][0-9]*
