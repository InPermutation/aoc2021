#!/usr/bin/env ruby
# frozen_string_literal: true

class Day18
  def part1
    magnitude(
      final_sum(
        add_all(
          lines.map(&Day18.method(:parse))
        )
      )
    )
  end

  def part2; end

  def self.final_sum(numbers)
    loop do
      exploded = explode_once(numbers)
      if exploded == numbers
        split = split_once(numbers)
        return numbers if split == numbers

        numbers = split
      else
        numbers = exploded
      end
    end
  end

  def self.add(left, right)
    raise AssertionError, "left #{left}" if left&.length != 2
    raise AssertionError, "right #{right}" if right&.length != 2

    [left, right].freeze
  end

  def self.add_all(numbers)
    numbers.reduce { |left, right| final_sum(add(left, right)) }
  end

  def self.split(regular_number)
    half = regular_number / 2
    rem = regular_number % 2
    [half, half + (rem.positive? ? 1 : 0)]
  end

  def self.split_once(number)
    number # TODO
  end

  def self.explode_once(number)
    number # TODO
  end

  def self.magnitude(sum)
    case sum
    in [], [_single], [_l, _r, *_rest]
      raise AssertionError, "not a pair #{sum}"
    in [l, r]
      3 * magnitude(l) + 2 * magnitude(r)
    else
      sum
    end
  end

  private

  attr_reader :lines

  def initialize(lines)
    @lines = lines
  end
end

class AssertionError < StandardError; end

def assert(msg = 'Assertion failed')
  raise AssertionError, msg unless yield

  printf '.'
end

def assert_equal(expected, actual)
  assert("\nExpect #{expected.inspect}\nActual #{actual.inspect}") { expected == actual }
end

assert_equal [[1, 2], [[3, 4], 5]], Day18.add([1, 2], [[3, 4], 5])
assert_equal [[1, 2], [[3, 4], 5]], Day18.add([1, 2], [[3, 4], 5])
assert_equal [[1, 2], [[3, 4], 5]], Day18.add([1, 2], [[3, 4], 5])
assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], Day18.add_all(
  [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
  ]
)
assert_equal [5, 5], Day18.split(10)
assert_equal [5, 6], Day18.split(11)
assert_equal [6, 6], Day18.split(12)

assert_equal [9, 3], Day18.split_once([9, 3]) # no split
assert_equal [[5, 5], 3], Day18.split_once([10, 3])
assert_equal [[5, 5], 11], Day18.split_once([10, 11])

assert_equal 29, Day18.magnitude([9, 1])
assert_equal 21, Day18.magnitude([1, 9])
assert_equal 129, Day18.magnitude([[9, 1], [1, 9]])
assert_equal 143, Day18.magnitude([[1, 2], [[3, 4], 5]])
assert_equal 1384, Day18.magnitude([[[[0, 7], 4], [[7, 8], [6, 0]]], [8, 1]])
assert_equal 445, Day18.magnitude([[[[1, 1], [2, 2]], [3, 3]], [4, 4]])
assert_equal 791, Day18.magnitude([[[[3, 0], [5, 3]], [4, 4]], [5, 5]])
assert_equal 1137, Day18.magnitude([[[[5, 0], [7, 4]], [5, 5]], [6, 6]])
assert_equal 3488, Day18.magnitude([[[[8, 7], [7, 7]], [[8, 6], [7, 7]]], [[[0, 7], [6, 6]], [8, 7]]])

assert_equal [5, [7, 2]], Day18.explode_once([5, [7, 2]]) # no explosion
assert_equal [[[[0, 9], 2], 3], 4], Day18.explode_once([[[[[9, 8], 1], 2], 3], 4])
assert_equal [7, [6, [5, [7, 0]]]], Day18.explode_once([7, [6, [5, [4, [3, 2]]]]])
assert_equal [[6, [5, [7, 0]]], 3], Day18.explode_once([[6, [5, [4, [3, 2]]]], 1])
assert_equal [[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]],
             Day18.explode_once([[3, [2, [1, [7, 3]]]], [6, [5, [4, [3, 2]]]]])
assert_equal [[3, [2, [8, 0]]], [9, [5, [7, 0]]]], Day18.explode_once([[3, [2, [8, 0]]], [9, [5, [4, [3, 2]]]]])

assert_equal [[[[1, 1], [2, 2]], [3, 3]], [4, 4]], Day18.final_sum(
  [
    [1, 1],
    [2, 2],
    [3, 3],
    [4, 4]
  ]
)

example_assignment = [
  [[[0, [5, 8]], [[1, 7], [9, 6]]], [[4, [1, 2]], [[1, 4], 2]]],
  [[[5, [2, 8]], 4], [5, [[9, 9], 0]]],
  [6, [[[6, 2], [5, 6]], [[7, 6], [4, 7]]]],
  [[[6, [0, 7]], [0, 9]], [4, [9, [9, 0]]]],
  [[[7, [6, 4]], [3, [1, 3]]], [[[5, 5], 1], 9]],
  [[6, [[7, 3], [3, 2]]], [[[3, 8], [5, 7]], 4]],
  [[[[5, 4], [7, 7]], 8], [[8, 3], 8]],
  [[9, 3], [[9, 9], [6, [4, 9]]]],
  [[2, [[7, 7], 7]], [[5, 8], [[9, 3], [0, 2]]]],
  [[[[5, 2], 5], [8, [3, 7]]], [[5, [7, 5]], [4, 4]]]
]
fsum = [[[[6, 6], [7, 6]], [[7, 7], [7, 0]]], [[[7, 7], [7, 7]], [[7, 8], [9, 9]]]]
assert_equal fsum, Day18.final_sum(example_assignment)
assert_equal 4140, Day18.magnitude(fsum)

puts "\nTests passed"

day18 = Day18.new(ARGF.map(&:chomp).freeze)
p part1: day18.part1
p part2: day18.part2
