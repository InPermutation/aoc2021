#!/usr/bin/env ruby
# frozen_string_literal: true

class Interpreter
  attr_accessor :w, :x, :y, :z

  def get(val_or_variable)
    #puts "get(#{val_or_variable})"
    send(val_or_variable)
  rescue
    val_or_variable.to_i
  end

  def set(variable, val)
    #puts "set(#{variable}, #{val})"
    send("#{variable}=", val)
  end

  def step(line)
    tokens = line.split(' ')
    instr = tokens[0]
    values = tokens.drop(1).map(&method(:get))

    #p instr: instr, values: values

    case instr
    when 'inp'
      if input_index >= input.length
        return :too_short
      end
      p input[input_index]
      set(tokens[1], input[input_index])
      @input_index = input_index + 1
    when 'add'
      set(tokens[1], values[0] + values[1])
    when 'mul'
      set(tokens[1], values[0] * values[1])
    when 'div'
      set(tokens[1], values[0] / values[1])
    when 'mod'
      set(tokens[1], values[0] % values[1])
    when 'eql'
      set(tokens[1], (values[0] == values[1]) ? 1 : 0)
    else
      raise NotImplementedError, instr
    end
    :ok
  end

  def run(lines)
    lines.each do |line|
      v = step(line)
      return v unless v == :ok
    end
  end

  private

  attr_reader :input
  attr_accessor :input_index

  def initialize(input)
    @w = @x = @y = @z = 0
    @input_index = 0
    @input = input
  end
end

class Day24
  def part1
  end

  def part2
  end

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end

day24 = Day24.new(ARGF.map(&:chomp).freeze)
p part1: day24.part1
p part2: day24.part2
