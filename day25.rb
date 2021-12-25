#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

class State
  attr_reader :right_moving, :down_moving, :width, :height

  def step
    new_right = right_moving
      .collect { |x, y| attempt_move([x, y], [x + 1, y]).freeze }
      .freeze

    after_right = State.new(new_right, down_moving, width, height)

    new_down = down_moving
      .collect { |x, y|
        v = after_right.attempt_move([x, y], [x, y + 1]).freeze
        if height == 9 and y == height
          p v
        end
        v
      }.freeze
    State.new(new_right, new_down, width, height)
  end

  def attempt_move(orig, attempt)
    ax, ay = attempt
    ax = ax % width
    ay = ay % height
    attempt = [ax, ay]
    self[attempt] == '.' ? attempt : orig
  end

  def self.from(lines)
    right_moving = []
    down_moving = []
    lines.each.with_index do |line, y|
      line.chars.each.with_index do |ch, x|
        case ch
        when '>'
          right_moving.push([x, y])
        when 'v'
          down_moving.push([x, y])
        when '.'
          next
        else
          raise "unknown ch #{ch} #{x},#{y}"
        end
      end
    end

    State.new(right_moving, down_moving, lines.first.length, lines.length)
  end

  def inspect
    lines = []
    height.times do |y|
      line = []
      width.times do |x|
        cuke = [x, y]
        line.push(self[cuke])
      end
      lines.push(line.join('').freeze)
    end
    lines.freeze
  end

  def [](pos)
    if right_moving.include? pos
      '>'
    elsif down_moving.include? pos
      'v'
    else
      '.'
    end
  end

  private

  def initialize(right_moving, down_moving, width, height)
    @right_moving = Set.new(right_moving).freeze
    @down_moving = Set.new(down_moving).freeze
    @width = width
    @height = height
  end
end

class Day25

  def part1
    p part1: cucumbers_init

    state = cucumbers_init
    i = 0
    loop do
      puts i
      nstate = state.step
      i += 1
      break if nstate.inspect == state.inspect
      state = nstate
    end
    i
  end

  def part2
  end

  private

  attr_reader :cucumbers_init

  def initialize(lines)
    @cucumbers_init = State.from(lines)
  end
end

puts "Testing..."
state =  State.from(['...>>>>>...'])
2.times { state = state.step }
raise StandardError, state.inspect unless state.inspect == ['...>>>.>.>.']

state = State.from(['..........', '.>v....v..', '.......>..', '..........'])
state = state.step
raise StandardError, "\n" + state.inspect.join("\n") unless
state.inspect == [
  '..........',
  '.>........',
  '..v....v>.',
  '..........']

state = State.from(%{...>...
.......
......>
v.....>
......>
.......
..vvv..}.split("\n"))
expected = %{After 1 step:
..vv>..
.......
>......
v.....>
>......
.......
....v..

After 2 steps:
....v>.
..vv...
.>.....
......>
v>.....
.......
.......

After 3 steps:
......>
..v.v..
..>v...
>......
..>....
v......
.......

After 4 steps:
>......
..v....
..>.v..
.>.v...
...>...
.......
v......
}.gsub(/After \d steps?:\n/, '').split("\n\n")
expected.each do |expect_value|
  state = state.step
  expect_value = expect_value.split("\n")
  raise StandardError, "\n#{expect_value} !=\n#{state.inspect}" unless state.inspect == expect_value
  puts "Step ok"
end

puts "Tests passed!"

day25 = Day25.new(ARGF.map(&:chomp).freeze)
p part1: day25.part1
p part2: day25.part2
